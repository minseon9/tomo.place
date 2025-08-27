package place.tomo.auth.domain.services

import kotlinx.coroutines.runBlocking
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.stereotype.Service
import place.tomo.auth.domain.dtos.AuthTokenDTO
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
import place.tomo.auth.domain.exception.AuthenticationFailedException
import place.tomo.auth.domain.exception.SocialAccountNotLinkedException
import place.tomo.auth.domain.services.oidc.OIDCProviderFactory
import place.tomo.contract.constant.OIDCProviderType

@Service
class AuthenticationService(
    private val authenticationManager: AuthenticationManager,
    private val socialAccountService: SocialAccountDomainService,
    private val jwtProvider: JwtProvider,
    private val oAuthServiceFactory: OIDCProviderFactory,
) {
    fun authenticateEmailPassword(
        email: String,
        password: String,
    ): AuthTokenDTO {
        try {
            val authentication =
                authenticationManager.authenticate(
                    UsernamePasswordAuthenticationToken(email, password),
                )

            val accessToken = jwtProvider.issueAccessToken(authentication.name)
            val refreshToken = jwtProvider.issueRefreshToken(authentication.name)

            return AuthTokenDTO(accessToken = accessToken, refreshToken = refreshToken)
        } catch (e: BadCredentialsException) {
            val reason = e.message ?: "이메일 또는 비밀번호가 올바르지 않습니다"
            throw AuthenticationFailedException(reason, e.cause)
        }
    }

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
