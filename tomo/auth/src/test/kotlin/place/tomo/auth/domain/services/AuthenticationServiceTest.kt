package place.tomo.auth.domain.services

import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import place.tomo.auth.domain.dtos.AuthTokenDTO
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
import place.tomo.auth.domain.exception.AuthenticationFailedException
import place.tomo.auth.domain.exception.SocialAccountNotLinkedException
import place.tomo.auth.domain.services.oidc.OIDCProvider
import place.tomo.auth.domain.services.oidc.OIDCProviderFactory
import place.tomo.contract.constant.OIDCProviderType

@DisplayName("AuthenticationService")
class AuthenticationServiceTest {
    private lateinit var authenticationManager: AuthenticationManager
    private lateinit var socialAccountService: SocialAccountDomainService
    private lateinit var oidcProviderFactory: OIDCProviderFactory
    private lateinit var jwtTokenProvider: JwtProvider
    private lateinit var service: AuthenticationService

    @BeforeEach
    fun setUp() {
        authenticationManager = mockk()
        socialAccountService = mockk()
        oidcProviderFactory = mockk()
        jwtTokenProvider = mockk()
        service = AuthenticationService(authenticationManager, socialAccountService, jwtTokenProvider, oidcProviderFactory)
    }

    @Nested
    @DisplayName("이메일/비밀번호 인증")
    inner class EmailPasswordAuth {
        @Test
        @DisplayName("유효한 이메일/비밀번호로 인증 성공 시 Access/Refresh 토큰을 발급한다")
        fun `authenticate email password when credentials valid expect access and refresh issued`() {
            val auth: Authentication = UsernamePasswordAuthenticationToken("user@example.com", "", emptyList())
            every { authenticationManager.authenticate(any()) } returns auth
            every { jwtTokenProvider.issueAccessToken("user@example.com") } returns "access"
            every { jwtTokenProvider.issueRefreshToken("user@example.com") } returns "refresh"

            val token: AuthTokenDTO = service.authenticateEmailPassword("user@example.com", "secret")

            assertThat(token).isEqualTo(AuthTokenDTO("access", "refresh"))
            verify { authenticationManager.authenticate(any()) }
        }

        @Test
        @DisplayName("잘못된 이메일/비밀번호로 인증 실패 시 예외를 전달한다")
        fun `authenticate email password when credentials invalid expect throws`() {
            every { authenticationManager.authenticate(any()) } throws BadCredentialsException("bad")

            assertThatThrownBy { service.authenticateEmailPassword("user@example.com", "bad") }
                .isInstanceOf(AuthenticationFailedException::class.java)
        }
    }

    @Nested
    @DisplayName("OIDC 인증")
    inner class OIDCAuth {
        @Test
        @DisplayName("활성 상태인 소셜 계정으로 OIDC 인증 성공 시 토큰을 발급한다")
        fun `authenticate oidc when social account active expect tokens issued`() {
            val provider = mockk<OIDCProvider>()
            val info =
                OIDCUserInfo(OIDCProviderType.GOOGLE, socialId = "sid", email = "user@example.com", name = "User", profileImageUrl = null)
            every { oidcProviderFactory.getService(OIDCProviderType.GOOGLE) } returns provider
            coEvery { provider.getOIDCUserInfo("code") } returns info
            every { socialAccountService.checkSocialAccount(OIDCProviderType.GOOGLE, "sid") } returns true
            every { jwtTokenProvider.issueAccessToken("user@example.com") } returns "a"
            every { jwtTokenProvider.issueRefreshToken("user@example.com") } returns "r"

            val token = service.authenticateOIDC(OIDCProviderType.GOOGLE, "code")

            assertThat(token).isEqualTo(AuthTokenDTO("a", "r"))
        }

        @Test
        @DisplayName("비활성 또는 미연결된 소셜 계정으로 OIDC 인증 시 접근 거부 예외를 던진다")
        fun `authenticate oidc when social account inactive or not linked expect 403 forbidden`() {
            val provider = mockk<OIDCProvider>()
            val info =
                OIDCUserInfo(OIDCProviderType.GOOGLE, socialId = "sid", email = "user@example.com", name = "User", profileImageUrl = null)
            every { oidcProviderFactory.getService(OIDCProviderType.GOOGLE) } returns provider
            coEvery { provider.getOIDCUserInfo("code") } returns info
            every { socialAccountService.checkSocialAccount(OIDCProviderType.GOOGLE, "sid") } returns false

            assertThatThrownBy { service.authenticateOIDC(OIDCProviderType.GOOGLE, "code") }
                .isInstanceOf(SocialAccountNotLinkedException::class.java)
                .extracting("status")
                .isEqualTo(HttpStatus.UNAUTHORIZED)
        }
    }

    @Nested
    @DisplayName("OIDC 사용자 토큰 발급")
    inner class IssueTokenForOIDCUser {
        @Test
        @DisplayName("OIDC 사용자 정보의 이메일을 subject로 하여 Access/Refresh 토큰을 발급한다")
        fun `issue access token when oidc user info provided expect access and refresh issued`() {
            val info =
                OIDCUserInfo(OIDCProviderType.GOOGLE, socialId = "sid", email = "user@example.com", name = "User", profileImageUrl = null)
            every { jwtTokenProvider.issueAccessToken("user@example.com") } returns "a"
            every { jwtTokenProvider.issueRefreshToken("user@example.com") } returns "r"

            val token = service.issueOIDCUserAuthToken(info)

            assertThat(token).isEqualTo(AuthTokenDTO("a", "r"))
        }
    }

    @Nested
    @DisplayName("OIDC 사용자 정보 조회")
    inner class GetOidcUserInfo {
        @Test
        @DisplayName("ProviderFactory에서 OIDC 서비스를 획득한 후 사용자 정보를 반환한다")
        fun `get oidc user info when provider and code valid expect user info returned`() {
            val provider = mockk<OIDCProvider>()
            val info =
                OIDCUserInfo(OIDCProviderType.GOOGLE, socialId = "sid", email = "user@example.com", name = "User", profileImageUrl = null)
            every { oidcProviderFactory.getService(OIDCProviderType.GOOGLE) } returns provider
            coEvery { provider.getOIDCUserInfo("code") } returns info

            val result = service.getOidcUserInfo(OIDCProviderType.GOOGLE, "code")

            assertThat(result).isEqualTo(info)
        }
    }
}
