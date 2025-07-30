package place.tomo.domain.services

import kotlinx.coroutines.runBlocking
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.stereotype.Service
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.domain.constant.OAuthProvider
import place.tomo.domain.services.oauth.OAuthClientFactory
import place.tomo.infra.repositories.SocialAccountRepository

@Service
class AuthenticationService(
    private val authenticationManager: AuthenticationManager,
    private val oAuthClientFactory: OAuthClientFactory,
    private val socialAccountRepository: SocialAccountRepository,
) {
    fun authenticateEmailPassword(
        email: String,
        password: String,
    ): UserInfoDTO {
        val authentication =
            authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken(email, password),
            )

        // FIXME:
        return UserInfoDTO(
            id = authentication.principal as Long,
            name = authentication.name,
            password = authentication.credentials.toString(),
            email = authentication.authorities.toString(),
        )
    }

    fun authenticateOAuth(
        provider: OAuthProvider,
        authorizationCode: String,
        idToken: String? = null,
    ): UserInfoDTO =
        runBlocking {
            val oAuthClient = oAuthClientFactory.getClient(provider)
            val tokenResponse = oAuthClient.getAccessToken(authorizationCode)
            val userInfo = oAuthClient.getUserInfo(tokenResponse.accessToken)

            val socialAccount =
                socialAccountRepository.findByProviderAndSocialIdAndIsActive(userInfo.provider, userInfo.socialId)
                    ?: throw IllegalStateException("해당 ${userInfo.name} 계정은 이미 다른 회원과 연결되어 있습니다.")

            // FIXME:
            UserInfoDTO(
                id = socialAccount.user.id,
                name = socialAccount.name ?: "",
                password = "",
                email = socialAccount.email ?: "",
            )
        }
}
