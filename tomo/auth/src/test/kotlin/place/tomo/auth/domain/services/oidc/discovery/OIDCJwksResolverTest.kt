package place.tomo.auth.domain.services.oidc.discovery

import io.mockk.coEvery
import io.mockk.coJustRun
import io.mockk.mockk
import io.mockk.spyk
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.test.runTest
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.auth.domain.services.oidc.OIDCTestHelper
import place.tomo.common.http.HttpClient
import place.tomo.contract.constant.OIDCProviderType
import java.security.interfaces.RSAPublicKey

@DisplayName("OIDCJwksResolver")
class OIDCJwksResolverTest {
    private lateinit var httpClient: HttpClient
    private lateinit var endpointResolver: OIDCEndpointResolver
    private lateinit var resolver: OIDCJwksResolver
    private lateinit var provider: OIDCProviderType

    private val endpoints = OIDCTestHelper.createEndpoints()
    private val testJwkKey = OIDCTestHelper.createJwkKey()
    private val testJwksResponse = OIDCTestHelper.createJwksResponse(listOf(testJwkKey))

    @BeforeEach
    fun setUp() {
        httpClient = mockk<HttpClient>()
        endpointResolver = mockk()
        provider = mockk<OIDCProviderType>()

        coEvery { endpointResolver.resolve(provider) } returns endpoints

        resolver = spyk(OIDCJwksResolver(httpClient, endpointResolver))
        resolver.self = resolver
    }

    @Nested
    @DisplayName("JWKS 조회")
    inner class GetJwks {
        @Test
        @DisplayName("정상적인 Provider로 JWKS 조회 성공")
        fun `get jwks when provider valid expect jwks returned`() {
            coEvery {
                httpClient.get(
                    endpoints.jwksUri,
                    query = null,
                    responseType = OIDCJwksResolver.JwksResponse::class.java,
                    accessToken = null,
                )
            } returns testJwksResponse

            val result = runBlocking { resolver.getJwks(provider) }

            assertThat(result.keys).hasSize(1)
            assertThat(result.keys.first().kid).isEqualTo(OIDCTestHelper.TEST_KID)
        }

        @Test
        @DisplayName("HTTP 요청 실패 시 예외 발생")
        fun `get jwks when http request fails expect throws exception`() {
            coEvery {
                httpClient.get(
                    endpoints.jwksUri,
                    query = null,
                    responseType = OIDCJwksResolver.JwksResponse::class.java,
                    accessToken = null,
                )
            } throws RuntimeException("HTTP request failed")

            assertThatThrownBy {
                runBlocking { resolver.getJwks(provider) }
            }.isInstanceOf(RuntimeException::class.java)
        }
    }

    @Nested
    @DisplayName("키 검색")
    inner class FindKeyByKid {
        @Test
        @DisplayName("유효한 JWK으로 RSA 공개키 변환 성공")
        fun `to rsa public key when jwk valid expect rsa public key returned`() {
            val jwk = OIDCTestHelper.createJwkKey() // 실제 RSA 키 사용

            val result = resolver.toRsaPublicKey(jwk)

            assertThat(result).isInstanceOf(RSAPublicKey::class.java)
        }

        @Test
        @DisplayName("일치하는 kid로 키 검색 성공")
        fun `find key by kid when kid matches expect key returned`() {
            coEvery { resolver.getJwks(provider) } returns testJwksResponse

            runTest {
                val result = resolver.findKeyByKid(provider, OIDCTestHelper.TEST_KID)

                assertThat(result).isNotNull()
                assertThat(result!!.kid).isEqualTo(OIDCTestHelper.TEST_KID)
            }
        }

        @Test
        @DisplayName("일치하는 kid가 없으면 null 반환")
        fun `find key by kid when kid not found expect null returned`() {
            val nonExistentKid = "non-existent-kid"
            val jwksResponseWithDifferentKid =
                OIDCTestHelper.createJwksResponse(
                    listOf(
                        OIDCTestHelper.createJwkKey(
                            kid = "different-kid",
                            alg = OIDCTestHelper.TEST_ALG,
                            n = OIDCTestHelper.TEST_MODULUS,
                            e = OIDCTestHelper.TEST_EXPONENT,
                        ),
                    ),
                )

            coEvery { resolver.self.getJwks(provider) } returns jwksResponseWithDifferentKid
            coJustRun { resolver.self.refresh(provider) }

            runTest {
                val result = resolver.findKeyByKid(provider, nonExistentKid)

                assertThat(result).isNull()
            }
        }

        @Test
        @DisplayName("캐시 갱신 후 재검색 성공")
        fun `find key by kid when cache refreshed expect key found`() {
            val firstJwksResponse = OIDCTestHelper.createJwksResponse(keys = emptyList())

            coEvery { resolver.getJwks(provider) } returns firstJwksResponse andThen testJwksResponse
            coEvery { resolver.refresh(provider) } returns testJwksResponse

            runTest {
                val result = resolver.findKeyByKid(provider, OIDCTestHelper.TEST_KID)

                assertThat(result).isNotNull()
                assertThat(result!!.kid).isEqualTo(OIDCTestHelper.TEST_KID)
            }
        }
    }

    @Nested
    @DisplayName("RSA 공개키 변환")
    inner class ToRsaPublicKey {
        @Test
        @DisplayName("유효한 JWK으로 RSA 공개키 변환 성공")
        fun `to rsa public key when jwk valid expect rsa public key returned`() {
            val jwk =
                OIDCTestHelper.createJwkKey(
                    kid = "test-kid",
                    alg = OIDCTestHelper.TEST_ALG,
                    n = OIDCTestHelper.TEST_MODULUS,
                    e = OIDCTestHelper.TEST_EXPONENT,
                )

            val result = resolver.toRsaPublicKey(jwk)

            assertThat(result).isInstanceOf(RSAPublicKey::class.java)
        }

        @Test
        @DisplayName("modulus가 없으면 예외 발생")
        fun `to rsa public key when modulus missing expect throws exception`() {
            val jwk =
                OIDCTestHelper.createJwkKey(
                    kid = "test-kid",
                    alg = OIDCTestHelper.TEST_ALG,
                    n = null, // modulus 없음
                    e = OIDCTestHelper.TEST_EXPONENT,
                )

            assertThatThrownBy {
                resolver.toRsaPublicKey(jwk)
            }.isInstanceOf(IllegalArgumentException::class.java)
        }

        @Test
        @DisplayName("exponent가 없으면 예외 발생")
        fun `to rsa public key when exponent missing expect throws exception`() {
            val jwk =
                OIDCTestHelper.createJwkKey(
                    kid = "test-kid",
                    alg = OIDCTestHelper.TEST_ALG,
                    n = OIDCTestHelper.TEST_EXPONENT,
                    e = null, // exponent 없음
                )

            assertThatThrownBy {
                resolver.toRsaPublicKey(jwk)
            }.isInstanceOf(IllegalArgumentException::class.java)
        }
    }
}
