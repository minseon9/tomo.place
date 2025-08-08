package place.tomo.auth.domain.services

import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.stereotype.Service
import place.tomo.auth.domain.dtos.AuthTokenDTO

@Service
class AuthenticationService(
    private val authenticationManager: AuthenticationManager,
//    private val oAuthServiceFactory: OIDCProviderFactory,
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

    fun authenticateOAuth(
        provider: OIDCProviderType,
        authorizationCode: String,
    ): AuthTokenDTO {
        val oidcUserInfo = getOidcUserInfo(provider, authorizationCode)

        val accessToken = jwtTokenProvider.issueAccessToken(oidcUserInfo.email)
        val refreshToken = jwtTokenProvider.issueRefreshToken(oidcUserInfo.email)

        return AuthTokenDTO(accessToken = accessToken, refreshToken = refreshToken)
    }

    fun getOidcUserInfo(
        provider: OIDCProviderType,
        authorizationCode: String,
    ): OidcUserInfo =
        runBlocking {
            val oAuthService = oAuthServiceFactory.getService(provider)
            val tokenResponse = oAuthService.getTokenResponse(authorizationCode)

            // ID token이 없는 경우 예외 처리
            val idToken =
                tokenResponse.idToken
                    ?: throw IllegalStateException("ID token is required for OIDC")

            oAuthService.getUserInfoFromIdToken(idToken)
        }
}
