package place.tomo.auth.domain.services.oidc.google

import com.fasterxml.jackson.databind.ObjectMapper
import io.jsonwebtoken.Jwts
import org.springframework.stereotype.Component
import place.tomo.auth.domain.dtos.oidc.OIDCIdTokenClaims
import place.tomo.auth.domain.exception.InvalidIdTokenException
import place.tomo.auth.domain.services.oidc.AbstractOIDCProvider
import place.tomo.auth.domain.services.oidc.OIDCProperties
import place.tomo.auth.domain.services.oidc.discovery.OIDCMetadataResolver
import place.tomo.contract.constant.OIDCProviderType

@Component
class GoogleOIDCProvider(
    googleOIDCClient: GoogleOIDCClient,
    properties: OIDCProperties,
    metadataResolver: OIDCMetadataResolver,
) : AbstractOIDCProvider(
        oidcClient = googleOIDCClient,
        oidcProperties = properties,
        metadataResolver = metadataResolver,
        providerType = OIDCProviderType.GOOGLE,
    ) {
    override suspend fun parseIdToken(idToken: String): OIDCIdTokenClaims {
        val headerJson =
            String(
                java.util.Base64
                    .getUrlDecoder()
                    .decode(idToken.substringBefore('.')),
            )
        val node = ObjectMapper().readTree(headerJson)
        val kid = node.path("kid").asText(null)
        val alg = node.path("alg").asText(null)
        if (kid.isNullOrBlank()) {
            throw InvalidIdTokenException("Missing kid in ID token header")
        }

        val publicKey = metadataResolver.getPublicKeyByKid(providerType, kid, alg)
        val claims =
            try {
                Jwts
                    .parser()
                    .verifyWith(publicKey)
                    .build()
                    .parseSignedClaims(idToken)
                    .payload
            } catch (e: Exception) {
                throw InvalidIdTokenException("Invalid ID token signature", e)
            }

        return OIDCIdTokenClaims(
            issuer = claims.issuer,
            subject = claims.subject,
            audiences = claims.audience?.toList() ?: emptyList(),
            expirationEpochSeconds = claims.expiration?.time?.div(1000) ?: 0L,
            issuedAtEpochSeconds = claims.issuedAt?.time?.div(1000) ?: 0L,
            email = claims["email"] as? String,
            emailVerified = (claims["email_verified"] as? Boolean),
            name = claims["name"] as? String,
            picture = claims["picture"] as? String,
        )
    }
}
