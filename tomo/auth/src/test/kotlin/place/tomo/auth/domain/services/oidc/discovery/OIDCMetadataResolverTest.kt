package place.tomo.auth.domain.services.oidc.discovery

import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.auth.domain.services.oidc.OIDCTestHelper
import place.tomo.contract.constant.OIDCProviderType
import java.security.interfaces.RSAPublicKey

@DisplayName("OIDCMetadataResolver")
class OIDCMetadataResolverTest {
    private lateinit var endpointsResolver: OIDCEndpointResolver
    private lateinit var jwksResolver: OIDCJwksResolver
    private lateinit var resolver: OIDCMetadataResolver
    private lateinit var mockProvider: OIDCProviderType

    @BeforeEach
    fun setUp() {
        endpointsResolver = mockk()
        jwksResolver = mockk()
        resolver = OIDCMetadataResolver(endpointsResolver, jwksResolver)
        mockProvider = mockk()
    }

    @Nested
    @DisplayName("엔드포인트 조회")
    inner class GetEndpoints {
        @Test
        @DisplayName("Provider로 엔드포인트 조회 성공")
        fun `get endpoints when provider valid expect endpoints returned`() {
            val expectedEndpoints = OIDCTestHelper.createEndpoints()

            coEvery { endpointsResolver.resolve(mockProvider) } returns expectedEndpoints

            val result = runBlocking { resolver.getEndpoints(mockProvider) }

            assertThat(result).isEqualTo(expectedEndpoints)
        }
    }

    @Nested
    @DisplayName("공개키 조회")
    inner class GetPublicKeyByKid {
        @Test
        @DisplayName("일치하는 kid로 공개키 조회 성공")
        fun `get public key by kid when kid matches expect public key returned`() {
            val kid = OIDCTestHelper.TEST_KID
            val alg = OIDCTestHelper.TEST_ALG
            val jwkKey = OIDCTestHelper.createJwkKey(kid, alg)
            val mockPublicKey = mockk<RSAPublicKey>()

            coEvery { jwksResolver.findKeyByKid(mockProvider, kid, alg) } returns jwkKey
            every { jwksResolver.toRsaPublicKey(jwkKey) } returns mockPublicKey

            val result = runBlocking { resolver.getPublicKeyByKid(mockProvider, kid, alg) }

            assertThat(result).isEqualTo(mockPublicKey)
        }

        @Test
        @DisplayName("일치하는 kid가 없으면 예외 발생")
        fun `get public key by kid when kid not found expect throws exception`() {
            val kid = "non-existent-kid"
            val alg = OIDCTestHelper.TEST_ALG

            coEvery { jwksResolver.findKeyByKid(mockProvider, kid, alg) } returns null

            assertThatThrownBy {
                runBlocking { resolver.getPublicKeyByKid(mockProvider, kid, alg) }
            }.isInstanceOf(IllegalArgumentException::class.java)
        }

        @Test
        @DisplayName("alg 파라미터 없이 공개키 조회 성공")
        fun `get public key by kid when alg not provided expect public key returned`() {
            val kid = OIDCTestHelper.TEST_KID
            val jwkKey = OIDCTestHelper.createJwkKey(kid, OIDCTestHelper.TEST_ALG)
            val mockPublicKey = mockk<RSAPublicKey>()

            coEvery { jwksResolver.findKeyByKid(mockProvider, kid, null) } returns jwkKey
            every { jwksResolver.toRsaPublicKey(jwkKey) } returns mockPublicKey

            val result = runBlocking { resolver.getPublicKeyByKid(mockProvider, kid) }

            assertThat(result).isEqualTo(mockPublicKey)
        }
    }
}
