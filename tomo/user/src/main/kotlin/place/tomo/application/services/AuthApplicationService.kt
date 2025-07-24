package place.tomo.application.services

import kotlinx.coroutines.runBlocking
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.application.commands.AuthenticationCommand
import place.tomo.application.commands.EmailPasswordAuthCommand
import place.tomo.application.commands.LoginCommand
import place.tomo.application.commands.OAuthAuthCommand
import place.tomo.application.commands.SignUpCommand
import place.tomo.domain.constant.OAuthProvider
import place.tomo.domain.services.SocialAccountDomainService
import place.tomo.domain.services.UserDomainService
import place.tomo.domain.services.oauth.OAuthClientFactory
import place.tomo.domain.services.strategies.authentication.AuthenticationStrategy

@Service
class AuthApplicationService(
    private val authenticationStrategies: List<AuthenticationStrategy>,
    private val userDomainService: UserDomainService,
    private val socialAccountDomainService: SocialAccountDomainService,
    private val oAuthClientFactory: OAuthClientFactory,
) {
    @Transactional
    fun signUp(command: SignUpCommand) {
        userDomainService.createUser(command.email, command.password, command.name)
    }

    fun login(command: LoginCommand): String {
        val authCommand = EmailPasswordAuthCommand(command.email, command.password)

        return authenticate(authCommand)
    }

    fun socialLogin(
        provider: OAuthProvider,
        authorizationCode: String,
    ): String {
        val authCommand = OAuthAuthCommand(provider, authorizationCode)
        return authenticate(authCommand)
    }

    @Transactional
    fun linkSocialAccount(
        userId: Long,
        provider: OAuthProvider,
        authorizationCode: String,
    ) {
        runBlocking {
            val oAuthClient = oAuthClientFactory.getClient(provider)

            val tokenResponse = oAuthClient.getAccessToken(authorizationCode)
            val userInfo = oAuthClient.getUserInfo(tokenResponse.accessToken)

            socialAccountDomainService.linkSocialAccount(
                userId = userId,
                provider = provider,
                socialId = userInfo.socialId,
                email = userInfo.email,
                name = userInfo.name,
                profileImageUrl = userInfo.profileImageUrl,
            )
        }
    }

    fun unlinkSocialAccount(
        userId: Long,
        provider: OAuthProvider,
    ) {
        socialAccountDomainService.unlinkSocialAccount(userId, provider)
    }

    fun getLinkedSocialAccounts(userId: Long) = socialAccountDomainService.getLinkedSocialAccounts(userId)

    fun getUserByEmail(email: String) = userDomainService.findByEmail(email)

    fun getUserById(id: Long) = userDomainService.findById(id)

    private fun authenticate(command: AuthenticationCommand): String {
        val strategy =
            authenticationStrategies.find { it.supports(command) }
                ?: throw IllegalArgumentException("지원하지 않는 인증 방식입니다.")

        return strategy.authenticate(command)
    }
}
