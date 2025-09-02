package place.tomo.auth.application.services

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.responses.LoginResponse
import place.tomo.auth.domain.commands.LinkSocialAccountCommand
import place.tomo.auth.domain.dtos.AuthTokenDTO
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
import place.tomo.auth.domain.services.AuthenticationService
import place.tomo.auth.domain.services.SocialAccountDomainService
import place.tomo.contract.constant.OIDCProviderType
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserDomainPort
import java.time.Instant

@DisplayName("OIDCApplicationService")
class OIDCApplicationServiceTest {
    private lateinit var authenticationService: AuthenticationService
    private lateinit var userDomainPort: UserDomainPort
    private lateinit var socialAccountService: SocialAccountDomainService
    private lateinit var service: OIDCApplicationService
    private val faker = Faker()

    @BeforeEach
    fun setUp() {
        authenticationService = mockk()
        userDomainPort = mockk()
        socialAccountService = mockk(relaxed = true)
        service = OIDCApplicationService(authenticationService, userDomainPort, socialAccountService)
    }

    @Nested
    @DisplayName("OIDC 회원가입/로그인 통합")
    inner class SignUpWithOIDC {
        @Test
        @DisplayName("OIDC 사용자 정보 조회 후 기존 사용자가 존재하면 새 사용자를 생성하지 않고 소셜 계정만 연결한다")
        fun `sign up when user already exists expect do not create`() {
            val email = faker.internet().emailAddress()
            val name = faker.name().fullName()
            val accessToken = faker.internet().password()
            val refreshToken = faker.internet().password()

            val oidcInfo =
                OIDCUserInfo(
                    OIDCProviderType.GOOGLE,
                    socialId = faker.internet().uuid(),
                    email = email,
                    name = name,
                    profileImageUrl = null,
                )
            val userInfo = UserInfoDTO(faker.number().numberBetween(1L, 1000L), email, name)
            val expectedAuthToken =
                AuthTokenDTO(
                    accessToken = accessToken,
                    refreshToken = refreshToken,
                    accessTokenExpiresAt = Instant.now().plusSeconds(3600),
                    refreshTokenExpiresAt = Instant.now().plusSeconds(86400),
                )

            every { authenticationService.getOidcUserInfo(OIDCProviderType.GOOGLE, any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns userInfo
            every { authenticationService.issueOIDCUserAuthToken(oidcInfo) } returns expectedAuthToken

            val res: LoginResponse =
                service.signUp(
                    OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()),
                )

            assertThat(res.accessToken).isEqualTo(accessToken)
            assertThat(res.accessTokenExpiresAt).isEqualTo(expectedAuthToken.accessTokenExpiresAt)
            assertThat(res.refreshTokenExpiresAt).isEqualTo(expectedAuthToken.refreshTokenExpiresAt)
            verify(exactly = 1) { userDomainPort.getOrCreateActiveUser(email, name) }
            verify(exactly = 1) { socialAccountService.linkSocialAccount(any<LinkSocialAccountCommand>()) }
        }

        @Test
        @DisplayName("기존 사용자가 없으면 임시 비밀번호를 생성하여 새 사용자를 생성하고 소셜 계정을 연결한다")
        fun `sign up when user not exists expect temporary password generated and user created`() {
            val email = faker.internet().emailAddress()
            val name = faker.name().fullName()
            faker.internet().password()
            val accessToken = faker.internet().password()
            val refreshToken = faker.internet().password()

            val oidcInfo =
                OIDCUserInfo(
                    OIDCProviderType.GOOGLE,
                    socialId = faker.internet().uuid(),
                    email = email,
                    name = name,
                    profileImageUrl = null,
                )
            val createdUserInfo = UserInfoDTO(faker.number().numberBetween(1L, 1000L), email, name)
            val expectedAuthToken =
                AuthTokenDTO(
                    accessToken = accessToken,
                    refreshToken = refreshToken,
                    accessTokenExpiresAt = Instant.now().plusSeconds(3600),
                    refreshTokenExpiresAt = Instant.now().plusSeconds(86400),
                )

            every { authenticationService.getOidcUserInfo(OIDCProviderType.GOOGLE, any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns createdUserInfo
            every { authenticationService.issueOIDCUserAuthToken(oidcInfo) } returns expectedAuthToken

            val res = service.signUp(OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()))

            assertThat(res.accessToken).isEqualTo(accessToken)
            assertThat(res.accessTokenExpiresAt).isEqualTo(expectedAuthToken.accessTokenExpiresAt)
            assertThat(res.refreshTokenExpiresAt).isEqualTo(expectedAuthToken.refreshTokenExpiresAt)
            verify { userDomainPort.getOrCreateActiveUser(email, name) }
            verify { socialAccountService.linkSocialAccount(any<LinkSocialAccountCommand>()) }
        }

        @Test
        @DisplayName("OIDC 회원가입 시 사용자가 존재하면 해당 사용자에 소셜 계정을 연결한다")
        fun `sign up when user found expect link social account`() {
            val socialId = faker.internet().uuid()
            val email = faker.internet().emailAddress()
            val name = faker.name().fullName()

            val oidcInfo =
                OIDCUserInfo(
                    OIDCProviderType.GOOGLE,
                    socialId = socialId,
                    email = email,
                    name = name,
                    profileImageUrl = faker.internet().url(),
                )
            val userInfo = UserInfoDTO(faker.number().numberBetween(1L, 1000L), email, name)

            every { authenticationService.getOidcUserInfo(any(), any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns userInfo
            every { authenticationService.issueOIDCUserAuthToken(oidcInfo) } returns
                AuthTokenDTO(
                    accessToken = faker.internet().password(),
                    refreshToken = faker.internet().password(),
                    accessTokenExpiresAt = Instant.now().plusSeconds(3600),
                    refreshTokenExpiresAt = Instant.now().plusSeconds(86400),
                )

            service.signUp(OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()))

            verify {
                socialAccountService.linkSocialAccount(
                    match {
                        it.user == userInfo &&
                            it.provider == OIDCProviderType.GOOGLE &&
                            it.socialId == socialId
                    },
                )
            }
        }

        @Test
        @DisplayName("OIDC 회원 가입 성공 시, 토큰 정보를 반환한다")
        fun `sign up when completed expect login response with tokens`() {
            val accessToken = faker.internet().password()
            val refreshToken = faker.internet().password()

            val oidcInfo =
                OIDCUserInfo(
                    OIDCProviderType.GOOGLE,
                    socialId = faker.internet().uuid(),
                    email = faker.internet().emailAddress(),
                    name = faker.name().fullName(),
                    profileImageUrl = null,
                )
            val userInfo =
                UserInfoDTO(
                    faker.number().numberBetween(1L, 1000L),
                    faker.internet().emailAddress(),
                    faker.name().fullName(),
                )
            val expectedAuthToken =
                AuthTokenDTO(
                    accessToken = accessToken,
                    refreshToken = refreshToken,
                    accessTokenExpiresAt = Instant.now().plusSeconds(3600),
                    refreshTokenExpiresAt = Instant.now().plusSeconds(86400),
                )
            val expectedLoginResponse =
                LoginResponse(
                    accessToken = accessToken,
                    refreshToken = refreshToken,
                    accessTokenExpiresAt = expectedAuthToken.accessTokenExpiresAt,
                    refreshTokenExpiresAt = expectedAuthToken.refreshTokenExpiresAt,
                )

            every { authenticationService.getOidcUserInfo(any(), any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(any(), any()) } returns userInfo
            every { authenticationService.issueOIDCUserAuthToken(oidcInfo) } returns expectedAuthToken

            val res = service.signUp(OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()))

            assertThat(res).isEqualTo(expectedLoginResponse)
        }

        @Test
        @DisplayName("비활성화된 사용자 OIDC 인증 시 403 Forbidden 예외 발생")
        fun `signup when deactivated user expect 403 forbidden exception`() {
            val email = faker.internet().emailAddress()
            val name = faker.name().fullName()

            val oidcInfo =
                OIDCUserInfo(
                    OIDCProviderType.GOOGLE,
                    socialId = faker.internet().uuid(),
                    email = email,
                    name = name,
                    profileImageUrl = null,
                )

            every { authenticationService.getOidcUserInfo(any(), any()) } returns oidcInfo
            every { userDomainPort.findActiveByEmail(email) } throws RuntimeException("비활성화된 사용자입니다.")

            assertThatThrownBy {
                service.signUp(OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()))
            }.isInstanceOf(RuntimeException::class.java)
        }
    }
}
