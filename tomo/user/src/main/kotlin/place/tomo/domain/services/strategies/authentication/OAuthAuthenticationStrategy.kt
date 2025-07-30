package place.tomo.domain.services.strategies.authentication

import kotlinx.coroutines.runBlocking
import org.springframework.stereotype.Component
import place.tomo.contract.constant.AuthenticationType
import place.tomo.domain.commands.AuthCredentials
import place.tomo.domain.commands.OAuthCredentials
import place.tomo.domain.services.oauth.OAuthClientFactory
import place.tomo.infra.repositories.SocialAccountRepository

@Component
class OAuthAuthenticationStrategy(
    private val oAuthClientFactory: OAuthClientFactory,
    private val socialAccountRepository: SocialAccountRepository,
) : AuthenticationStrategy() {
    override fun supports(type: AuthenticationType): Boolean = type == AuthenticationType.OAUTH

    override fun authenticate(credentials: AuthCredentials): String =
        runBlocking {
            val oauthCreds = credentials as OAuthCredentials

            val oAuthClient = oAuthClientFactory.getClient(oauthCreds.provider)
            val tokenResponse = oAuthClient.getAccessToken(oauthCreds.code)
            val userInfo = oAuthClient.getUserInfo(tokenResponse.accessToken)

            val socialAccount =
                socialAccountRepository.findByProviderAndSocialIdAndIsActive(userInfo.provider, userInfo.socialId)
                    ?: throw IllegalStateException("해당 ${userInfo.name} 계정은 이미 다른 회원과 연결되어 있습니다.")

            socialAccount.user.email
        }
}
