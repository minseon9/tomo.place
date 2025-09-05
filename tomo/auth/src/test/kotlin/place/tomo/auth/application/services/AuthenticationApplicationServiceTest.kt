package place.tomo.auth.application.services

import io.mockk.every
import io.mockk.justRun
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
import place.tomo.auth.application.requests.RefreshTokenRequest
import place.tomo.auth.application.responses.IssueTokenResponse
import place.tomo.auth.domain.commands.LinkSocialAccountCommand
import place.tomo.auth.domain.dtos.JwtToken
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
import place.tomo.auth.domain.exception.InvalidRefreshTokenException
import place.tomo.auth.domain.services.AuthenticationService
import place.tomo.auth.domain.services.SocialAccountDomainService
import place.tomo.auth.domain.services.jwt.JwtProvider
import place.tomo.auth.domain.services.jwt.JwtValidator
import place.tomo.contract.constant.OIDCProviderType
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserDomainPort
import java.time.Instant

@DisplayName("AuthenticationApplicationService")
class AuthenticationApplicationServiceTest {
    private lateinit var authenticationService: AuthenticationService
    private lateinit var jwtProvider: JwtProvider
    private lateinit var jwtValidator: JwtValidator
    private lateinit var userDomainPort: UserDomainPort
    private lateinit var socialAccountService: SocialAccountDomainService
    private lateinit var service: AuthenticationApplicationService
    private val faker = Faker()

    @BeforeEach
    fun setUp() {
        authenticationService = mockk()
        jwtProvider = mockk()
        jwtValidator = mockk()
        userDomainPort = mockk()
        socialAccountService = mockk(relaxed = true)
        service =
            AuthenticationApplicationService(
                authenticationService,
                jwtProvider,
                jwtValidator,
                userDomainPort,
                socialAccountService,
            )
    }

    @Nested
    @DisplayName("OIDC 회원가입/로그인 통합")
    inner class SignUpWithOIDC {
        @Test
        @DisplayName("OIDC 사용자 정보 조회 후 기존 사용자가 존재하면 새 사용자를 생성하지 않고 소셜 계정만 연결한다")
        fun `sign up when user already exists expect do not create`() {
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
            val userInfo = UserInfoDTO(faker.number().numberBetween(1L, 1000L), email, name)
            every { authenticationService.getOidcUserInfo(OIDCProviderType.GOOGLE, any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns userInfo

            val accessToken = issueToken(false)
            val refreshToken = issueToken(true)
            every { jwtProvider.issueAccessToken(email) } returns accessToken
            every { jwtProvider.issueRefreshToken(email) } returns refreshToken

            service.signUp(
                OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()),
            )

            IssueTokenResponse.fromJwtTokens(accessToken, refreshToken)
            verify(exactly = 1) { userDomainPort.getOrCreateActiveUser(email, name) }
            verify(exactly = 1) { socialAccountService.linkSocialAccount(any<LinkSocialAccountCommand>()) }
        }

        @Test
        @DisplayName("기존 사용자가 없으면 임시 비밀번호를 생성하여 새 사용자를 생성하고 소셜 계정을 연결한다")
        fun `sign up when user not exists expect temporary password generated and user created`() {
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
            val createdUserInfo = UserInfoDTO(faker.number().numberBetween(1L, 1000L), email, name)
            every { authenticationService.getOidcUserInfo(OIDCProviderType.GOOGLE, any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns createdUserInfo

            val accessToken = issueToken(false)
            val refreshToken = issueToken(true)
            every { jwtProvider.issueAccessToken(email) } returns accessToken
            every { jwtProvider.issueRefreshToken(email) } returns refreshToken

            val response =
                service.signUp(
                    OIDCSignUpRequest(
                        OIDCProviderType.GOOGLE,
                        authorizationCode = faker.internet().password(),
                    ),
                )

            val expectedIssueTokenResponse =
                IssueTokenResponse.fromJwtTokens(accessToken, refreshToken)
            assertThat(response).isEqualTo(expectedIssueTokenResponse)
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

            val accessToken = issueToken(false)
            val refreshToken = issueToken(true)
            every { jwtProvider.issueAccessToken(email) } returns accessToken
            every { jwtProvider.issueRefreshToken(email) } returns refreshToken

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
            every { authenticationService.getOidcUserInfo(any(), any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(any(), any()) } returns userInfo

            val accessToken = issueToken(false)
            val refreshToken = issueToken(true)
            every { jwtProvider.issueAccessToken(any()) } returns accessToken
            every { jwtProvider.issueRefreshToken(any()) } returns refreshToken

            val response =
                service.signUp(
                    OIDCSignUpRequest(
                        OIDCProviderType.GOOGLE,
                        authorizationCode = faker.internet().password(),
                    ),
                )

            val expectedIssueTokenResponse =
                IssueTokenResponse.fromJwtTokens(accessToken, refreshToken)
            assertThat(response).isEqualTo(expectedIssueTokenResponse)
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
                service.signUp(
                    OIDCSignUpRequest(
                        OIDCProviderType.GOOGLE,
                        authorizationCode = faker.internet().password(),
                    ),
                )
            }.isInstanceOf(RuntimeException::class.java)
        }
    }

    @Nested
    @DisplayName("토큰 갱신")
    inner class RefreshToken {
        @Test
        @DisplayName("유효한 refresh token으로 요청 시 새로운 토큰을 반환한다")
        fun `refresh token when valid expect new tokens returned`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()
            val request = RefreshTokenRequest(userEmail, refreshToken)

            justRun { jwtValidator.validateRefreshToken(userEmail, refreshToken) }

            val newAccessToken = issueToken(false)
            val newRefreshToken = issueToken(true)
            every { jwtProvider.issueAccessToken(userEmail) } returns newAccessToken
            every { jwtProvider.issueRefreshToken(userEmail) } returns newRefreshToken

            val result = service.refreshToken(request)

            val expectedResult = IssueTokenResponse.fromJwtTokens(newAccessToken, newRefreshToken)
            assertThat(result).isEqualTo(expectedResult)
        }

        @Test
        @DisplayName("유효하지 않은 refresh token으로 요청 시 예외를 던진다")
        fun `refresh token when invalid expect exception thrown`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()

            val request = RefreshTokenRequest(userEmail, refreshToken)

            every {
                jwtValidator.validateRefreshToken(userEmail, refreshToken)
            } throws InvalidRefreshTokenException("유효하지 않은 토큰입니다.")

            assertThatThrownBy { service.refreshToken(request) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
                .hasMessage("유효하지 않은 토큰입니다.")
        }
    }

    private fun issueToken(isRefresh: Boolean): JwtToken {
        val token = faker.internet().password()

        val secondsToAdd =
            if (isRefresh) {
                3600L
            } else {
                86400L
            }
        val expiresAt = Instant.now().plusSeconds(secondsToAdd)

        return JwtToken(token, expiresAt)
    }
}
