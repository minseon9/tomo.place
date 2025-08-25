package place.tomo.auth.domain.services.oidc.discovery

import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.boot.autoconfigure.security.oauth2.client.OAuth2ClientProperties
import place.tomo.auth.domain.services.oidc.OIDCTestHelper
import place.tomo.contract.constant.OIDCProviderType

@DisplayName("OAuthClientPropsResolver")
class OAuthClientPropsResolverTest {
    private lateinit var properties: OAuth2ClientProperties
    private lateinit var resolver: OAuthClientPropsResolver
    private lateinit var mockProvider: OIDCProviderType

    @BeforeEach
    fun setUp() {
        properties = mockk()
        resolver = OAuthClientPropsResolver(properties)
        mockProvider = mockk()
        every { mockProvider.name } returns OIDCTestHelper.TEST_PROVIDER_NAME
    }

    @Nested
    @DisplayName("Issuer 조회")
    inner class GetIssuer {
        @Test
        @DisplayName("설정된 Provider의 issuer 반환")
        fun `get issuer when provider configured expect issuer returned`() {
            val mockProviderConfig = mockk<OAuth2ClientProperties.Provider>()

            every { properties.provider } returns mapOf(OIDCTestHelper.TEST_PROVIDER_NAME to mockProviderConfig)
            every { mockProviderConfig.issuerUri } returns OIDCTestHelper.TEST_ISSUER

            val result = resolver.getIssuer(mockProvider)

            assertThat(result).isEqualTo(OIDCTestHelper.TEST_ISSUER)
        }

        @Test
        @DisplayName("설정되지 않은 Provider 요청 시 null 반환")
        fun `get issuer when provider not configured expect null returned`() {
            every { properties.provider } returns emptyMap()

            val result = resolver.getIssuer(mockProvider)

            assertThat(result).isNull()
        }

        @Test
        @DisplayName("Provider 설정은 있지만 issuer-uri가 없으면 null 반환")
        fun `get issuer when provider configured but issuer uri missing expect null returned`() {
            val mockProviderConfig = mockk<OAuth2ClientProperties.Provider>()

            every { properties.provider } returns mapOf(OIDCTestHelper.TEST_PROVIDER_NAME to mockProviderConfig)
            every { mockProviderConfig.issuerUri } returns null

            val result = resolver.getIssuer(mockProvider)

            assertThat(result).isNull()
        }

        @Test
        @DisplayName("대소문자 구분 없이 Provider 이름 매칭")
        fun `get issuer when provider name case insensitive expect issuer returned`() {
            val mockProviderConfig = mockk<OAuth2ClientProperties.Provider>()

            every { properties.provider } returns mapOf(OIDCTestHelper.TEST_PROVIDER_NAME to mockProviderConfig)
            every { mockProviderConfig.issuerUri } returns OIDCTestHelper.TEST_ISSUER

            val result = resolver.getIssuer(mockProvider)

            assertThat(result).isEqualTo(OIDCTestHelper.TEST_ISSUER)
        }
    }
}
