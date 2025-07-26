package place.tomo.domain.services.strategies.authentication

import kotlinx.coroutines.runBlocking
import org.springframework.stereotype.Component
import place.tomo.domain.constant.OAuthProvider
import place.tomo.domain.services.oauth.OAuthClientFactory
import place.tomo.infra.repositories.SocialAccountRepository

class OAuthAuthenticationStrategy internal constructor(
    private val oAuthClientFactory: OAuthClientFactory,
    private val socialAccountRepository: SocialAccountRepository,
    private val provider: OAuthProvider,
    private val authorizationCode: String,
) : AuthenticationStrategy {
    override fun authenticate(): String =
        runBlocking {
            val oAuthClient = oAuthClientFactory.getClient(provider)
            val tokenResponse = oAuthClient.getAccessToken(authorizationCode)
            val userInfo = oAuthClient.getUserInfo(tokenResponse.accessToken)

            val socialAccount =
                socialAccountRepository.findByProviderAndSocialIdAndIsActive(userInfo.provider, userInfo.socialId)
                    ?: throw IllegalStateException("해당 ${userInfo.name} 계정은 이미 다른 회원과 연결되어 있습니다.")

            socialAccount.user.email
        }
}

@Component
class OAuthStrategy(
    private val userRepository: UserRepository,
    private val oauthClientFactory: place.tomo.application.services.OAuthClientFactory,
) : AuthenticationStrategy<OAuthCredentials>() {
    override fun authenticate(credentials: OAuthCredentials): AuthResult =
        try {
            val client = oauthClientFactory.getClient(credentials.provider)
            val userInfo = client.exchangeCodeForUserInfo(credentials.code)

            val user =
                userRepository.findBySocialId(userInfo.id)
                    ?: createSocialUser(userInfo)

            createAuthResult(user)
        } catch (e: Exception) {
            AuthResult.Failure("OAuth authentication failed: ${e.message}")
        }

    override fun supports(type: AuthType): Boolean = type == AuthType.OAUTH

    private fun createSocialUser(userInfo: OAuthUserInfo): User =
        userRepository.save(
            User(
                email = userInfo.email,
                socialId = userInfo.id,
                provider = userInfo.provider,
                name = userInfo.name,
            ),
        )
}
