package place.tomo.auth.domain.services.oidc.discovery

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker
import io.github.resilience4j.retry.annotation.Retry
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.cache.annotation.CachePut
import org.springframework.cache.annotation.Cacheable
import org.springframework.context.annotation.Lazy
import org.springframework.stereotype.Component
import place.tomo.auth.domain.dtos.oidc.OIDCEndpoints
import place.tomo.common.exception.HttpErrorStatus
import place.tomo.common.exception.HttpException
import place.tomo.common.http.HttpClient
import place.tomo.common.http.get
import place.tomo.contract.constant.OIDCProviderType

@Component
class OIDCEndpointResolver(
    private val httpClient: HttpClient,
    private val propsResolver: OAuthClientPropsResolver,
) {
    @Autowired
    @Lazy
    lateinit var self: OIDCEndpointResolver

    @Retry(name = "oidc-endpoints")
    @CircuitBreaker(name = "oidc-endpoints")
    @Cacheable(cacheNames = ["oidc-endpoints"], key = "#provider")
    suspend fun resolve(provider: OIDCProviderType): OIDCEndpoints {
        val issuer =
            propsResolver.getIssuer(provider)
                ?: throw HttpException(HttpErrorStatus.INTERNAL_SERVER_ERROR, "issuer-uri not configured for $provider")

        val wellKnownUri = issuer.trimEnd('/') + "/.well-known/openid-configuration"
        val resp = httpClient.get<WellKnownResponse>(wellKnownUri)

        return OIDCEndpoints(
            issuer = resp.issuer,
            authorizationEndpoint = resp.authorization_endpoint,
            tokenEndpoint = resp.token_endpoint,
            userinfoEndpoint = resp.userinfo_endpoint,
            jwksUri = resp.jwks_uri,
        )
    }

    @Retry(name = "oidc-endpoints")
    @CircuitBreaker(name = "oidc-endpoints")
    @CachePut(cacheNames = ["oidc-endpoints"], key = "#provider")
    suspend fun refresh(provider: OIDCProviderType): OIDCEndpoints = self.resolve(provider)

    private data class WellKnownResponse(
        val issuer: String,
        val authorization_endpoint: String?,
        val token_endpoint: String,
        val userinfo_endpoint: String?,
        val jwks_uri: String,
    )
}
