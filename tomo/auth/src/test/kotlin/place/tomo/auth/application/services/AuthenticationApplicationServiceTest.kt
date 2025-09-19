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
import org.springframework.http.HttpStatus
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
import place.tomo.common.exception.NotFoundActiveUserException
import place.tomo.contract.constant.OIDCProviderType
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserDomainPort
import java.time.Instant
import java.util.UUID

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
            val name = faker.name().username()

            val userInfo = createUserInfo(email, name)
            val oidcInfo = createOidcUserInfo(email, name)

            every { authenticationService.getOidcUserInfo(oidcInfo.provider, any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns userInfo

            val accessToken = issueToken(false)
            val refreshToken = issueToken(true)
            every { jwtProvider.issueAccessToken(userInfo.entityId.toString()) } returns accessToken
            every { jwtProvider.issueRefreshToken(userInfo.entityId.toString()) } returns refreshToken

            service.signUp(
                OIDCSignUpRequest(oidcInfo.provider, authorizationCode = faker.internet().password()),
            )

            IssueTokenResponse.fromJwtTokens(accessToken, refreshToken)
            verify(exactly = 1) { userDomainPort.getOrCreateActiveUser(email, name) }
            verify(exactly = 1) { socialAccountService.linkSocialAccount(any<LinkSocialAccountCommand>()) }
        }

        @Test
        @DisplayName("기존 사용자가 없으면 임시 비밀번호를 생성하여 새 사용자를 생성하고 소셜 계정을 연결한다")
        fun `sign up when user not exists expect temporary password generated and user created`() {
            val email = faker.internet().emailAddress()
            val name = faker.name().username()

            val userInfo = createUserInfo(email, name)
            val oidcInfo = createOidcUserInfo(email, name)

            every { authenticationService.getOidcUserInfo(oidcInfo.provider, any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns userInfo

            val accessToken = issueToken(false)
            val refreshToken = issueToken(true)
            every { jwtProvider.issueAccessToken(userInfo.entityId.toString()) } returns accessToken
            every { jwtProvider.issueRefreshToken(userInfo.entityId.toString()) } returns refreshToken

            val response =
                service.signUp(
                    OIDCSignUpRequest(
                        oidcInfo.provider,
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
            val email = faker.internet().emailAddress()
            val name = faker.name().username()

            val userInfo = createUserInfo(email, name)
            val oidcInfo = createOidcUserInfo(email, name)

            every { authenticationService.getOidcUserInfo(any(), any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns userInfo

            val accessToken = issueToken(false)
            val refreshToken = issueToken(true)
            every { jwtProvider.issueAccessToken(userInfo.entityId.toString()) } returns accessToken
            every { jwtProvider.issueRefreshToken(userInfo.entityId.toString()) } returns refreshToken

            service.signUp(OIDCSignUpRequest(oidcInfo.provider, authorizationCode = faker.internet().password()))

            verify {
                socialAccountService.linkSocialAccount(
                    match {
                        it.user == userInfo &&
                            it.provider == oidcInfo.provider &&
                            it.socialId == oidcInfo.socialId
                    },
                )
            }
        }

        @Test
        @DisplayName("OIDC 회원 가입 성공 시, 토큰 정보를 반환한다")
        fun `sign up when completed expect login response with tokens`() {
            val email = faker.internet().emailAddress()
            val name = faker.name().username()

            val userInfo = createUserInfo(email, name)
            val oidcInfo = createOidcUserInfo(email, name)

            every { authenticationService.getOidcUserInfo(oidcInfo.provider, any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } returns userInfo

            val accessToken = issueToken(false)
            val refreshToken = issueToken(true)
            every { jwtProvider.issueAccessToken(any()) } returns accessToken
            every { jwtProvider.issueRefreshToken(any()) } returns refreshToken

            val response =
                service.signUp(
                    OIDCSignUpRequest(
                        oidcInfo.provider,
                        authorizationCode = faker.internet().password(),
                    ),
                )

            val expectedIssueTokenResponse =
                IssueTokenResponse.fromJwtTokens(accessToken, refreshToken)
            assertThat(response).isEqualTo(expectedIssueTokenResponse)
        }

        @Test
        @DisplayName("비활성화된 사용자 OIDC 인증 시 401 Unauthorized 예외 발생")
        fun `signup when deactivated user expect 401 unauthorized exception`() {
            val email = faker.internet().emailAddress()
            val name = faker.name().username()
            val oidcInfo = createOidcUserInfo(email, name)

            every { authenticationService.getOidcUserInfo(oidcInfo.provider, any()) } returns oidcInfo
            every { userDomainPort.getOrCreateActiveUser(email, name) } throws NotFoundActiveUserException(email)

            assertThatThrownBy {
                service.signUp(
                    OIDCSignUpRequest(
                        oidcInfo.provider,
                        authorizationCode = faker.internet().password(),
                    ),
                )
            }.isInstanceOf(NotFoundActiveUserException::class.java)
                .extracting("status")
                .isEqualTo(HttpStatus.UNAUTHORIZED)
        }
    }

    @Nested
    @DisplayName("토큰 갱신")
    inner class RefreshToken {
        @Test
        @DisplayName("유효한 refresh token으로 요청 시 새로운 토큰을 반환한다")
        fun `refresh token when valid expect new tokens returned`() {
            val refreshToken = faker.internet().password()
            val email = faker.internet().emailAddress()
            val userInfo = createUserInfo(email)

            every { jwtValidator.validateRefreshToken(refreshToken) } returns email
            every { userDomainPort.findActiveByEntityId(email) } returns userInfo

            val newAccessToken = issueToken(false)
            val newRefreshToken = issueToken(true)
            every { jwtProvider.issueAccessToken(email) } returns newAccessToken
            every { jwtProvider.issueRefreshToken(email) } returns newRefreshToken

            val result = service.refreshToken(RefreshTokenRequest(refreshToken))

            val expectedResult = IssueTokenResponse.fromJwtTokens(newAccessToken, newRefreshToken)
            assertThat(result).isEqualTo(expectedResult)
        }

        @Test
        @DisplayName("유효하지 않은 refresh token으로 요청 시 예외를 던진다")
        fun `refresh token when invalid expect exception thrown`() {
            val refreshToken = faker.internet().password()

            every {
                jwtValidator.validateRefreshToken(refreshToken)
            } throws InvalidRefreshTokenException("유효하지 않은 토큰입니다.")

            assertThatThrownBy { service.refreshToken(RefreshTokenRequest(refreshToken)) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
        }

        @Test
        @DisplayName("활성화된 사용자가 아닌 subject의 refresh token으로 요청 시 예외를 던진다")
        fun `refresh token when subject is not active user expect exception thrown`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()

            every {
                jwtValidator.validateRefreshToken(refreshToken)
            } returns userEmail
            every { userDomainPort.findActiveByEntityId(userEmail) } throws NotFoundActiveUserException(userEmail)

            assertThatThrownBy { service.refreshToken(RefreshTokenRequest(refreshToken)) }
                .isInstanceOf(NotFoundActiveUserException::class.java)
        }
    }

    private fun createUserInfo(
        email: String = faker.internet().emailAddress(),
        name: String = faker.name().username(),
    ): UserInfoDTO = UserInfoDTO(faker.number().numberBetween(1L, 1000L), UUID.randomUUID(), email, name)

    private fun createOidcUserInfo(
        email: String = faker.internet().emailAddress(),
        name: String = faker.name().username(),
    ): OIDCUserInfo =
        OIDCUserInfo(
            OIDCProviderType.GOOGLE,
            socialId = faker.internet().uuid(),
            email = email,
            name = name,
            profileImageUrl = null,
        )

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
