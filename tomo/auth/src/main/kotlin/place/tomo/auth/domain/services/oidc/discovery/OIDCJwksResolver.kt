package place.tomo.auth.domain.services.oidc.discovery

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker
import io.github.resilience4j.retry.annotation.Retry
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.cache.annotation.CachePut
import org.springframework.cache.annotation.Cacheable
import org.springframework.context.annotation.Lazy
import org.springframework.stereotype.Component
import place.tomo.common.http.HttpClient
import place.tomo.common.http.get
import place.tomo.contract.constant.OIDCProviderType
import java.math.BigInteger
import java.security.KeyFactory
import java.security.interfaces.RSAPublicKey
import java.security.spec.RSAPublicKeySpec
import java.util.Base64

@Component
class OIDCJwksResolver(
    private val httpClient: HttpClient,
    private val endpointResolver: OIDCEndpointResolver,
) {
    private val keyType = "RSA"

    @Autowired
    @Lazy
    lateinit var self: OIDCJwksResolver

    @Retry(name = "oidc-jwks")
    @CircuitBreaker(name = "oidc-jwks")
    @Cacheable(cacheNames = ["oidc-jwks"], key = "#provider")
    suspend fun getJwks(provider: OIDCProviderType): JwksResponse {
        val endpoints = endpointResolver.resolve(provider)

        return httpClient.get<JwksResponse>(endpoints.jwksUri)
    }

    @Retry(name = "oidc-jwks")
    @CircuitBreaker(name = "oidc-jwks")
    @CachePut(cacheNames = ["oidc-jwks"], key = "#provider")
    suspend fun refresh(provider: OIDCProviderType): JwksResponse {
        val endpoints = endpointResolver.resolve(provider)

        return httpClient.get<JwksResponse>(endpoints.jwksUri)
    }

    suspend fun findKeyByKid(
        provider: OIDCProviderType,
        kid: String,
        alg: String? = null,
    ): JwkKey? {
        self
            .getJwks(provider)
            .keys
            .firstOrNull { matchesKidAndAlg(it, kid, alg) }
            ?.let { return it }

        self.refresh(provider)

        return self.getJwks(provider).keys.firstOrNull { matchesKidAndAlg(it, kid, alg) }
    }

    fun toRsaPublicKey(jwk: JwkKey): RSAPublicKey {
        val modulus = requireNotNull(jwk.n) { "Missing modulus(n) in JWK" }
        val exponent = requireNotNull(jwk.e) { "Missing exponent(e) in JWK" }

        val n = BigInteger(1, Base64.getUrlDecoder().decode(modulus))
        val e = BigInteger(1, Base64.getUrlDecoder().decode(exponent))
        val spec = RSAPublicKeySpec(n, e)

        return KeyFactory.getInstance(keyType).generatePublic(spec) as RSAPublicKey
    }

    private fun matchesKidAndAlg(
        key: JwkKey,
        kid: String,
        alg: String?,
    ): Boolean {
        if (key.kty != keyType) return false
        if (key.kid != kid) return false
        if (key.use != null && key.use != "sig") return false
        if (alg != null && key.alg != null && key.alg != alg) return false

        return true
    }

    data class JwksResponse(
        val keys: List<JwkKey>,
    )

    data class JwkKey(
        val kty: String,
        val use: String?,
        val kid: String?,
        val alg: String?,
        val n: String?,
        val e: String?,
        val x5c: List<String>?,
    )
}
