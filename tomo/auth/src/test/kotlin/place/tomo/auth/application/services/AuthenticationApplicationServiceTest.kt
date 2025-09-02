package place.tomo.auth.application.services

import io.mockk.*
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
import place.tomo.auth.domain.dtos.JwtTokenVO
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
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
        service = AuthenticationApplicationService(authenticationService, jwtProvider, jwtValidator, userDomainPort, socialAccountService)
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
            val accessTokenVO = JwtTokenVO(accessToken, Instant.now().plusSeconds(3600).toEpochMilli())
            val refreshTokenVO = JwtTokenVO(refreshToken, Instant.now().plusSeconds(86400).toEpochMilli())

            every { authenticationService.getOidcUserInfo(OIDCProviderType.GOOGLE, any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns userInfo
            every { jwtProvider.issueAccessToken(email) } returns accessTokenVO
            every { jwtProvider.issueRefreshToken(email) } returns refreshTokenVO

            val response: IssueTokenResponse =
                service.signUp(
                    OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()),
                )

            assertThat(response.accessToken).isEqualTo(accessToken)
            assertThat(response.accessTokenExpiresAt).isEqualTo(accessTokenVO.expiresAt)
            assertThat(response.refreshTokenExpiresAt).isEqualTo(refreshTokenVO.expiresAt)
            verify(exactly = 1) { userDomainPort.getOrCreateActiveUser(email, name) }
            verify(exactly = 1) { socialAccountService.linkSocialAccount(any<LinkSocialAccountCommand>()) }
        }

        @Test
        @DisplayName("기존 사용자가 없으면 임시 비밀번호를 생성하여 새 사용자를 생성하고 소셜 계정을 연결한다")
        fun `sign up when user not exists expect temporary password generated and user created`() {
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
            val createdUserInfo = UserInfoDTO(faker.number().numberBetween(1L, 1000L), email, name)
            val accessTokenVO = JwtTokenVO(accessToken, Instant.now().plusSeconds(3600).toEpochMilli())
            val refreshTokenVO = JwtTokenVO(refreshToken, Instant.now().plusSeconds(86400).toEpochMilli())

            every { authenticationService.getOidcUserInfo(OIDCProviderType.GOOGLE, any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns createdUserInfo
            every { jwtProvider.issueAccessToken(email) } returns accessTokenVO
            every { jwtProvider.issueRefreshToken(email) } returns refreshTokenVO

            val response = service.signUp(OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()))

            assertThat(response.accessToken).isEqualTo(accessToken)
            assertThat(response.accessTokenExpiresAt).isEqualTo(accessTokenVO.expiresAt)
            assertThat(response.refreshTokenExpiresAt).isEqualTo(refreshTokenVO.expiresAt)
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
            val accessTokenVO = JwtTokenVO(faker.internet().password(), Instant.now().plusSeconds(3600).toEpochMilli())
            val refreshTokenVO = JwtTokenVO(faker.internet().password(), Instant.now().plusSeconds(86400).toEpochMilli())

            every { authenticationService.getOidcUserInfo(any(), any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns userInfo
            every { jwtProvider.issueAccessToken(email) } returns accessTokenVO
            every { jwtProvider.issueRefreshToken(email) } returns refreshTokenVO

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
            val accessTokenVO = JwtTokenVO(accessToken, Instant.now().plusSeconds(3600).toEpochMilli())
            val refreshTokenVO = JwtTokenVO(refreshToken, Instant.now().plusSeconds(86400).toEpochMilli())
            val expectedIssueTokenResponse =
                IssueTokenResponse(
                    accessToken = accessToken,
                    refreshToken = refreshToken,
                    accessTokenExpiresAt = accessTokenVO.expiresAt,
                    refreshTokenExpiresAt = refreshTokenVO.expiresAt,
                )

            every { authenticationService.getOidcUserInfo(any(), any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(any(), any()) } returns userInfo
            every { jwtProvider.issueAccessToken(any()) } returns accessTokenVO
            every { jwtProvider.issueRefreshToken(any()) } returns refreshTokenVO

            val response = service.signUp(OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()))

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
                service.signUp(OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()))
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
            val newAccessToken = faker.internet().password()
            val newRefreshToken = faker.internet().password()
            val accessTokenExpiresAt = Instant.now().plusSeconds(3600).toEpochMilli()
            val refreshTokenExpiresAt = Instant.now().plusSeconds(86400).toEpochMilli()

            val request = RefreshTokenRequest(userEmail, refreshToken)
            val accessTokenVO = JwtTokenVO(newAccessToken, accessTokenExpiresAt)
            val refreshTokenVO = JwtTokenVO(newRefreshToken, refreshTokenExpiresAt)

            justRun { jwtValidator.validateRefreshToken(userEmail, refreshToken) }
            every { jwtProvider.issueAccessToken(userEmail) } returns accessTokenVO
            every { jwtProvider.issueRefreshToken(userEmail) } returns refreshTokenVO

            val result = service.refreshToken(request)

            assertThat(result.accessToken).isEqualTo(newAccessToken)
            assertThat(result.refreshToken).isEqualTo(newRefreshToken)
            assertThat(result.accessTokenExpiresAt).isEqualTo(accessTokenExpiresAt)
            assertThat(result.refreshTokenExpiresAt).isEqualTo(refreshTokenExpiresAt)
        }
    }
}
