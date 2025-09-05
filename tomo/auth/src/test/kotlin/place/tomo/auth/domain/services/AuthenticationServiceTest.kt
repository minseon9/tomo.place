package place.tomo.auth.domain.services

import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import place.tomo.auth.domain.dtos.JwtToken
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
import place.tomo.auth.domain.exception.SocialAccountNotLinkedException
import place.tomo.auth.domain.services.oidc.OIDCProvider
import place.tomo.auth.domain.services.oidc.OIDCProviderFactory
import place.tomo.contract.constant.OIDCProviderType
import java.time.Instant

@DisplayName("AuthenticationService")
class AuthenticationServiceTest {
    private lateinit var socialAccountService: SocialAccountDomainService
    private lateinit var oidcProviderFactory: OIDCProviderFactory
    private lateinit var jwtTokenProvider: JwtProvider
    private lateinit var service: AuthenticationService

    @BeforeEach
    fun setUp() {
        socialAccountService = mockk()
        oidcProviderFactory = mockk()
        jwtTokenProvider = mockk()
        service = AuthenticationService(socialAccountService, jwtTokenProvider, oidcProviderFactory)
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

            val accessToken = JwtToken("a", Instant.now().plusSeconds(3600))
            val refreshToken = JwtToken("r", Instant.now().plusSeconds(86400))
            every { jwtTokenProvider.issueAccessToken("user@example.com") } returns accessToken
            every { jwtTokenProvider.issueRefreshToken("user@example.com") } returns refreshToken

            val token = service.authenticateOIDC(OIDCProviderType.GOOGLE, "code")

            assertThat(token.accessToken).isEqualTo("a")
            assertThat(token.refreshToken).isEqualTo("r")
            assertThat(token.accessTokenExpiresAt).isEqualTo(accessToken.expiresAt.toEpochMilli())
            assertThat(token.refreshTokenExpiresAt).isEqualTo(refreshToken.expiresAt.toEpochMilli())
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
            val accessToken = JwtToken("a", Instant.now().plusSeconds(3600))
            val refreshToken = JwtToken("r", Instant.now().plusSeconds(86400))
            every { jwtTokenProvider.issueAccessToken("user@example.com") } returns accessToken
            every { jwtTokenProvider.issueRefreshToken("user@example.com") } returns refreshToken

            val token = service.issueOIDCUserAuthToken(info)

            assertThat(token.accessToken).isEqualTo("a")
            assertThat(token.refreshToken).isEqualTo("r")
            assertThat(token.accessTokenExpiresAt).isEqualTo(accessToken.expiresAt.toEpochMilli())
            assertThat(token.refreshTokenExpiresAt).isEqualTo(refreshToken.expiresAt.toEpochMilli())
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
