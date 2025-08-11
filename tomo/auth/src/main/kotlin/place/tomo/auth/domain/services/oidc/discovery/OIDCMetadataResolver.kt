package place.tomo.auth.domain.services.oidc.discovery

import org.springframework.stereotype.Component
import place.tomo.auth.domain.dtos.oidc.OIDCEndpoints
import place.tomo.contract.constant.OIDCProviderType
import java.security.interfaces.RSAPublicKey

@Component
class OIDCMetadataResolver(
    private val endpointsResolver: OIDCEndpointResolver,
    private val jwksResolver: OIDCJwksResolver,
) {
    suspend fun getEndpoints(provider: OIDCProviderType): OIDCEndpoints = endpointsResolver.resolve(provider)

    suspend fun getPublicKeyByKid(
        provider: OIDCProviderType,
        kid: String,
        alg: String? = null,
    ): RSAPublicKey {
        val jwkKey = jwksResolver.findKeyByKid(provider, kid, alg)
        requireNotNull(jwkKey) { "No matching JWK found for kid=$kid" }

        return jwksResolver.toRsaPublicKey(jwkKey)
    }
}
