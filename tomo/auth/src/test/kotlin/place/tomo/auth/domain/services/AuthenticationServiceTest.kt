package place.tomo.auth.domain.services

import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
import place.tomo.auth.domain.services.oidc.OIDCProvider
import place.tomo.auth.domain.services.oidc.OIDCProviderFactory
import place.tomo.contract.constant.OIDCProviderType

@DisplayName("AuthenticationService")
class AuthenticationServiceTest {
    private lateinit var oidcProviderFactory: OIDCProviderFactory
    private lateinit var service: AuthenticationService

    @BeforeEach
    fun setUp() {
        oidcProviderFactory = mockk()
        service = AuthenticationService(oidcProviderFactory)
    }

    @Nested
    @DisplayName("OIDC 사용자 정보 조회")
    inner class GetOidcUserInfo {
        @Test
        @DisplayName("ProviderFactory에서 OIDC 서비스를 획득한 후 사용자 정보를 반환한다")
        fun `get oidc user info when provider and code valid expect user info returned`() {
            val provider = mockk<OIDCProvider>()
            val info =
                OIDCUserInfo(
                    OIDCProviderType.GOOGLE,
                    socialId = "sid",
                    email = "user@example.com",
                    name = "User",
                    profileImageUrl = null,
                )
            every { oidcProviderFactory.getService(OIDCProviderType.GOOGLE) } returns provider
            coEvery { provider.getOIDCUserInfo("code") } returns info

            val result = service.getOidcUserInfo(OIDCProviderType.GOOGLE, "code")

            assertThat(result).isEqualTo(info)
        }
    }
}
