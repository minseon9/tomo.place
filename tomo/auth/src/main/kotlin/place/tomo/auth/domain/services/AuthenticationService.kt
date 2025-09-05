package place.tomo.auth.domain.services

import kotlinx.coroutines.runBlocking
import org.springframework.stereotype.Service
import place.tomo.auth.domain.dtos.AuthTokenDTO
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
import place.tomo.auth.domain.exception.SocialAccountNotLinkedException
import place.tomo.auth.domain.services.oidc.OIDCProviderFactory
import place.tomo.contract.constant.OIDCProviderType

@Service
class AuthenticationService(
    private val socialAccountService: SocialAccountDomainService,
    private val jwtProvider: JwtProvider,
    private val oAuthServiceFactory: OIDCProviderFactory,
) {
    fun authenticateOIDC(
        provider: OIDCProviderType,
        authorizationCode: String,
    ): AuthTokenDTO {
        val oidcUserInfo = getOidcUserInfo(provider, authorizationCode)
        if (!socialAccountService.checkSocialAccount(oidcUserInfo.provider, oidcUserInfo.socialId)) {
            throw SocialAccountNotLinkedException(provider)
        }

        return issueOIDCUserAuthToken(oidcUserInfo)
    }

    fun issueOIDCUserAuthToken(oidcUserInfo: OIDCUserInfo): AuthTokenDTO {
        val accessToken = jwtProvider.issueAccessToken(oidcUserInfo.email)
        val refreshToken = jwtProvider.issueRefreshToken(oidcUserInfo.email)

        return AuthTokenDTO(
            accessToken = accessToken.token,
            refreshToken = refreshToken.token,
            accessTokenExpiresAt = accessToken.expiresAt.toEpochMilli(),
            refreshTokenExpiresAt = refreshToken.expiresAt.toEpochMilli(),
        )
    }

    fun getOidcUserInfo(
        provider: OIDCProviderType,
        authorizationCode: String,
    ): OIDCUserInfo =
        runBlocking {
            val service = oAuthServiceFactory.getService(provider)
            service.getOIDCUserInfo(authorizationCode)
        }
}
