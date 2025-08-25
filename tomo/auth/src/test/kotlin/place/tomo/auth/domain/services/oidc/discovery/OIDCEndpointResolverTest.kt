package place.tomo.auth.domain.services.oidc.discovery

import io.mockk.coEvery
import io.mockk.every
import io.mockk.impl.annotations.SpyK
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.spyk
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.test.runTest
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.auth.domain.exception.OIDCConfigurationException
import place.tomo.auth.domain.services.oidc.OIDCTestHelper
import place.tomo.common.http.HttpClient
import place.tomo.contract.constant.OIDCProviderType

@DisplayName("OIDCEndpointResolver")
class OIDCEndpointResolverTest {
    private lateinit var httpClient: HttpClient
    private lateinit var propsResolver: OAuthClientPropsResolver
    private lateinit var resolver: OIDCEndpointResolver
    private lateinit var mockProvider: OIDCProviderType

    @BeforeEach
    fun setUp() {
        httpClient = mockk()
        propsResolver = mockk()
        resolver = spyk(OIDCEndpointResolver(httpClient, propsResolver))
        resolver.self = resolver
        mockProvider = mockk()
    }

    @Nested
    @DisplayName("OIDC 엔드포인트 조회")
    inner class Resolve {
        @Test
        @DisplayName("정상적인 Provider로 엔드포인트 조회 성공")
        fun `resolve when provider valid expect endpoints returned`() {
            val wellKnownResponse = OIDCTestHelper.createWellKnownResponse()

            every { propsResolver.getIssuer(mockProvider) } returns OIDCTestHelper.TEST_ISSUER
            coEvery {
                httpClient.get(
                    uri = OIDCTestHelper.TEST_ISSUER.trimEnd('/') + OIDCTestHelper.TEST_WELL_KNOWN_PATH,
                    query = null,
                    responseType = OIDCEndpointResolver.WellKnownResponse::class.java,
                    accessToken = null,
                )
            } returns wellKnownResponse

            runTest {
                val result = resolver.resolve(mockProvider)

                assertThat(result.issuer).isEqualTo(OIDCTestHelper.TEST_ISSUER)
                assertThat(result.authorizationEndpoint).isEqualTo(OIDCTestHelper.TEST_AUTH_ENDPOINT)
                assertThat(result.tokenEndpoint).isEqualTo(OIDCTestHelper.TEST_TOKEN_ENDPOINT)
                assertThat(result.userinfoEndpoint).isEqualTo(OIDCTestHelper.TEST_USERINFO_ENDPOINT)
                assertThat(result.jwksUri).isEqualTo(OIDCTestHelper.TEST_JWKS_URI)
            }
        }

        @Test
        @DisplayName("issuer-uri가 설정되지 않은 Provider 요청 시 OIDCConfigurationException 발생")
        fun `resolve when issuer uri not configured expect throws configuration exception`() {
            every { propsResolver.getIssuer(mockProvider) } returns null

            assertThatThrownBy {
                runBlocking { resolver.resolve(mockProvider) }
            }.isInstanceOf(OIDCConfigurationException::class.java)
        }

        @Test
        @DisplayName("HTTP 요청 실패 시 예외 발생")
        fun `resolve when http request fails expect throws exception`() {
            every { propsResolver.getIssuer(mockProvider) } returns OIDCTestHelper.TEST_ISSUER
            coEvery {
                httpClient.get(
                    uri = OIDCTestHelper.TEST_ISSUER.trimEnd('/') + OIDCTestHelper.TEST_WELL_KNOWN_PATH,
                    query = null,
                    responseType = OIDCEndpointResolver.WellKnownResponse::class.java,
                    accessToken = null,
                )
            } throws RuntimeException("HTTP request failed")

            assertThatThrownBy {
                runBlocking { resolver.resolve(mockProvider) }
            }.isInstanceOf(RuntimeException::class.java)
        }
    }

    @Nested
    @DisplayName("캐시 갱신")
    inner class Refresh {
        @Test
        @DisplayName("캐시 갱신 시 새로운 엔드포인트 정보 반환")
        fun `refresh when called expect new endpoints returned`() {
            val wellKnownResponse = OIDCTestHelper.createWellKnownResponse()

            every { propsResolver.getIssuer(mockProvider) } returns OIDCTestHelper.TEST_ISSUER
            coEvery {
                httpClient.get(
                    uri = OIDCTestHelper.TEST_ISSUER.trimEnd('/') + OIDCTestHelper.TEST_WELL_KNOWN_PATH,
                    query = null,
                    responseType = OIDCEndpointResolver.WellKnownResponse::class.java,
                    accessToken = null,
                )
            } returns wellKnownResponse

            runTest {
                val result = resolver.refresh(mockProvider)

                assertThat(result.issuer).isEqualTo(OIDCTestHelper.TEST_ISSUER)
                assertThat(result.tokenEndpoint).isEqualTo(OIDCTestHelper.TEST_TOKEN_ENDPOINT)
            }
        }
    }
}
