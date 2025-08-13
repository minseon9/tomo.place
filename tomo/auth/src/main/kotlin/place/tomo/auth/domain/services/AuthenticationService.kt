package place.tomo.auth.domain.services

import kotlinx.coroutines.runBlocking
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.stereotype.Service
import place.tomo.auth.domain.dtos.AuthTokenDTO
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
import place.tomo.auth.domain.services.oidc.OIDCProviderFactory
import place.tomo.common.exception.HttpErrorStatus
import place.tomo.common.exception.HttpException
import place.tomo.contract.constant.OIDCProviderType

@Service
class AuthenticationService(
    private val authenticationManager: AuthenticationManager,
    private val socialAccountService: SocialAccountDomainService,
    private val oAuthServiceFactory: OIDCProviderFactory,
    private val jwtTokenProvider: JwtTokenProvider,
) {
    fun authenticateEmailPassword(
        email: String,
        password: String,
    ): AuthTokenDTO {
        val authentication =
            authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken(email, password),
            )

        val accessToken = jwtTokenProvider.issueAccessToken(authentication.name)
        val refreshToken = jwtTokenProvider.issueRefreshToken(authentication.name)

        return AuthTokenDTO(accessToken = accessToken, refreshToken = refreshToken)
    }

    fun authenticateOIDC(
        provider: OIDCProviderType,
        authorizationCode: String,
    ): AuthTokenDTO {
        val oidcUserInfo = getOidcUserInfo(provider, authorizationCode)
        if (!socialAccountService.checkSocialAccount(oidcUserInfo.provider, oidcUserInfo.socialId)) {
            throw HttpException(HttpErrorStatus.FORBIDDEN, "해당 ${oidcUserInfo.provider} 계정이 비활성화되었거나 없습니다.")
        }

        return issueOIDCUserAuthToken(oidcUserInfo)
    }

    fun issueOIDCUserAuthToken(oidcUserInfo: OIDCUserInfo): AuthTokenDTO {
        val accessToken = jwtTokenProvider.issueAccessToken(oidcUserInfo.email)
        val refreshToken = jwtTokenProvider.issueRefreshToken(oidcUserInfo.email)

        return AuthTokenDTO(accessToken = accessToken, refreshToken = refreshToken)
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
