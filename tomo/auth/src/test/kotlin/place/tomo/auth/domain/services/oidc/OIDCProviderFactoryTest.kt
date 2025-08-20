package place.tomo.auth.domain.services.oidc

import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.auth.domain.services.oidc.google.GoogleOIDCProvider
import place.tomo.contract.constant.OIDCProviderType

@DisplayName("OIDCProviderFactory")
class OIDCProviderFactoryTest {
    private lateinit var googleOIDCProvider: GoogleOIDCProvider
    private lateinit var factory: OIDCProviderFactory

    @BeforeEach
    fun setUp() {
        googleOIDCProvider = mockk()
        factory = OIDCProviderFactory(googleOIDCProvider)
    }

    @Nested
    @DisplayName("Provider 인스턴스 조회")
    inner class GetService {
        @Test
        @DisplayName("GOOGLE Provider 요청 시 GoogleOIDCProvider 반환")
        fun `get service when provider is google expect google provider returned`() {
            val provider = factory.getService(OIDCProviderType.GOOGLE)

            assertThat(provider).isEqualTo(googleOIDCProvider)
        }

        @Test
        @DisplayName("지원하지 않는 Provider 요청 시 예외 발생")
        fun `get service when provider not supported expect throws unsupported operation`() {
            val notSupportedProvider = listOf(OIDCProviderType.KAKAO, OIDCProviderType.KAKAO)

            notSupportedProvider.forEach { provider ->
                assertThatThrownBy {
                    factory.getService(provider)
                }.isInstanceOf(UnsupportedOperationException::class.java)
            }
        }
    }
}
