package place.tomo.application.services

import kotlinx.coroutines.runBlocking
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.application.requests.OAuthAuthenticateRequest
import place.tomo.domain.commands.LinkSocialAccountCommand
import place.tomo.domain.commands.OAuthLoginCommand
import place.tomo.domain.constant.OAuthProvider
import place.tomo.domain.services.AuthenticationService
import place.tomo.domain.services.SocialAccountDomainService
import place.tomo.domain.services.oauth.OAuthClientFactory

@Service
class OauthApplicationService(
    private val authenticateService: AuthenticationService,
    private val socialAccountDomainService: SocialAccountDomainService,
    private val oAuthClientFactory: OAuthClientFactory,
) {
    // FIXME: oAuthClientFactory는 Domain에서 처리하도록 수정
    @Transactional
    fun linkSocialAccount(
        provider: OAuthProvider,
        authorizationCode: String,
    ) {
        // FIXME: 권한 있는 지 확인
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

    fun authenticate(request: OAuthAuthenticateRequest): String =
        authenticateService.authenticate(command = OAuthLoginCommand(request.provider, request.authorizationCode))

    fun unlinkSocialAccount(
        userId: Long,
        provider: OAuthProvider,
    ) {
        // FIXME: 삭제 권한 있는 지 확인
        socialAccountDomainService.unlinkSocialAccount(userId, provider)
    }
}
