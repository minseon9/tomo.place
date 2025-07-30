package place.tomo.application.services

import kotlinx.coroutines.runBlocking
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.application.requests.OAuthAuthenticateRequest
import place.tomo.domain.commands.LinkSocialAccountCommand
import place.tomo.domain.constant.OAuthProvider
import place.tomo.domain.services.AuthenticationService
import place.tomo.domain.services.JwtTokenProvider
import place.tomo.domain.services.SocialAccountDomainService
import place.tomo.domain.services.oauth.OAuthClientFactory

@Service
class OauthApplicationService(
    private val authenticateService: AuthenticationService,
    private val socialAccountDomainService: SocialAccountDomainService,
    private val oAuthClientFactory: OAuthClientFactory,
    private val jwtTokenProvider: JwtTokenProvider,
) {
    @Transactional
    fun linkSocialAccount(
        provider: OAuthProvider,
        authorizationCode: String,
    ) {
        runBlocking {
            val oAuthClient = oAuthClientFactory.getClient(provider)
            val tokenResponse = oAuthClient.getAccessToken(authorizationCode)
            val userInfo = oAuthClient.getUserInfo(tokenResponse.accessToken)

            socialAccountDomainService.linkSocialAccount(
                LinkSocialAccountCommand(
                    provider = provider,
                    socialId = userInfo.socialId,
                    email = userInfo.email,
                    name = userInfo.name,
                    profileImageUrl = userInfo.profileImageUrl,
                ),
            )
        }
    }

    fun authenticate(request: OAuthAuthenticateRequest): String {
        val userInfo = authenticateService.authenticateOAuth(request.provider, request.authorizationCode)

        return jwtTokenProvider.issueToken(userInfo.email)
    }

    fun unlinkSocialAccount(
        userId: Long,
        provider: OAuthProvider,
    ) {
        // FIXME: 삭제 권한 있는 지 확인
        socialAccountDomainService.unlinkSocialAccount(userId, provider)
    }
}
