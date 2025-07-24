package place.tomo.domain.services.strategies.authentication

import kotlinx.coroutines.runBlocking
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import place.tomo.application.commands.AuthenticationCommand
import place.tomo.application.commands.OAuthAuthCommand
import place.tomo.domain.entities.UserEntity
import place.tomo.domain.models.OAuthUserInfo
import place.tomo.domain.services.JwtTokenProvider
import place.tomo.domain.services.SocialAccountDomainService
import place.tomo.domain.services.UserDomainService
import place.tomo.domain.services.oauth.OAuthClientFactory
import java.util.UUID

@Component
class OAuthAuthenticationStrategy(
    private val oAuthClientFactory: OAuthClientFactory,
    private val socialAccountDomainService: SocialAccountDomainService,
    private val userDomainService: UserDomainService,
    private val jwtTokenProvider: JwtTokenProvider,
    private val passwordEncoder: PasswordEncoder,
) : AuthenticationStrategy {
    override fun supports(command: AuthenticationCommand): Boolean = command is OAuthAuthCommand

    @Transactional
    override fun authenticate(command: AuthenticationCommand): String {
        require(command is OAuthAuthCommand) { "지원하지 않는 인증 방식입니다." }

        return runBlocking {
            val oAuthClient = oAuthClientFactory.getClient(command.provider)

            // 1. 액세스 토큰 획득
            val tokenResponse = oAuthClient.getAccessToken(command.authorizationCode)

            // 2. 사용자 정보 조회
            val userInfo = oAuthClient.getUserInfo(tokenResponse.accessToken)

            // 3. 기존 소셜 계정으로 가입된 회원 찾기
            val existingSocialAccount = socialAccountDomainService.findBySocialAccount(command.provider, userInfo.socialId)
            val existingUser = existingSocialAccount?.email?.let { userDomainService.findByEmail(it) }

            if (existingUser != null) {
                // 기존 회원 로그인
                return@runBlocking jwtTokenProvider.issueToken(existingUser.email)
            }

            // 4. 이메일로 기존 회원 찾기 (계정 연결)
            val userByEmail = userInfo.email?.let { userDomainService.findByEmail(it) }

            val user =
                if (userByEmail != null) {
                    // 기존 회원에 소셜 계정 연결
                    socialAccountDomainService.linkSocialAccount(
                        userId = userByEmail.id,
                        provider = command.provider,
                        socialId = userInfo.socialId,
                        email = userInfo.email,
                        name = userInfo.name,
                        profileImageUrl = userInfo.profileImageUrl,
                    )
                    userByEmail
                } else {
                    // 신규 회원 생성
                    val newUser = createNewUserFromSocial(userInfo)
                    socialAccountDomainService.linkSocialAccount(
                        userId = newUser.id,
                        provider = command.provider,
                        socialId = userInfo.socialId,
                        email = userInfo.email,
                        name = userInfo.name,
                        profileImageUrl = userInfo.profileImageUrl,
                    )
                    newUser
                }

            jwtTokenProvider.issueToken(user.email)
        }
    }

    private fun createNewUserFromSocial(userInfo: OAuthUserInfo): UserEntity {
        val email = userInfo.email ?: throw IllegalArgumentException("소셜 로그인에서 이메일을 가져올 수 없습니다.")
        val name = userInfo.name ?: "사용자"

        // 소셜 로그인 사용자는 임시 패스워드 설정
        val tempPassword = passwordEncoder.encode(UUID.randomUUID().toString())

        return userDomainService.createUser(email, tempPassword, name)
    }
}
