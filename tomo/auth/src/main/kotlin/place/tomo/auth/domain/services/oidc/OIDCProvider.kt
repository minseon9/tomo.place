package place.tomo.auth.domain.services.oidc

import place.tomo.auth.domain.dtos.oidc.OIDCEndpoints
import place.tomo.auth.domain.dtos.oidc.OIDCIdTokenClaims
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
import place.tomo.auth.domain.services.oidc.discovery.OIDCMetadataResolver
import place.tomo.common.exception.HttpErrorStatus
import place.tomo.common.exception.HttpException
import place.tomo.contract.constant.OIDCProviderType

interface OIDCProvider {
    suspend fun getOIDCUserInfo(
        authorizationCode: String,
        state: String? = null,
    ): OIDCUserInfo
}

abstract class AbstractOIDCProvider(
    protected val oidcClient: OIDCClient,
    protected val oidcProperties: OIDCProperties,
    protected val metadataResolver: OIDCMetadataResolver,
    protected val providerType: OIDCProviderType,
) : OIDCProvider {
    override suspend fun getOIDCUserInfo(
        authorizationCode: String,
        state: String?,
    ): OIDCUserInfo {
        val oidcToken = oidcClient.getOIDCToken(authorizationCode)

        val claims = parseIdToken(oidcToken.idToken)

        val endpoints = metadataResolver.getEndpoints(providerType)

        validateIdToken(claims, endpoints)

        return OIDCUserInfo(
            provider = providerType,
            socialId = claims.subject,
            email = claims.email ?: "",
            name = claims.name ?: "",
            profileImageUrl = claims.picture,
        )
    }

    protected open suspend fun parseIdToken(idToken: String): OIDCIdTokenClaims {
        // NOTE: 상속받은 provider 별로 구현
        throw HttpException(HttpErrorStatus.UNPROCESSABLE_ENTITY, "ID token claims not supported")
    }

    protected open fun validateIdToken(
        claims: OIDCIdTokenClaims,
        endpoints: OIDCEndpoints,
    ) {
        if (claims.issuer != endpoints.issuer) {
            throw HttpException(HttpErrorStatus.UNAUTHORIZED, "Invalid issuer in ID token")
        }

        if (!claims.audiences.contains(oidcProperties.clientId)) {
            throw HttpException(HttpErrorStatus.UNAUTHORIZED, "Invalid audience in ID token")
        }

        val now = System.currentTimeMillis() / 1000
        if (claims.expirationEpochSeconds <= now) {
            throw HttpException(HttpErrorStatus.UNAUTHORIZED, "ID token has expired")
        }

        ensureEmailRequired(claims)
    }

    protected open fun ensureEmailRequired(claims: OIDCIdTokenClaims) {
        val email = claims.email
        val verified = claims.emailVerified
        if (email.isNullOrBlank()) {
            throw HttpException(HttpErrorStatus.UNAUTHORIZED, "Email not found in ID token")
        }
        if (verified != null && verified == false) {
            throw HttpException(HttpErrorStatus.UNAUTHORIZED, "Email is not verified")
        }
    }
}
