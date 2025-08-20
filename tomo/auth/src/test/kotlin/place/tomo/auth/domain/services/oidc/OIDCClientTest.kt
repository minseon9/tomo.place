package place.tomo.auth.domain.services.oidc

import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.auth.domain.dtos.oidc.OIDCTokens
import place.tomo.auth.domain.exception.OIDCTokenExchangeFailedException
import place.tomo.common.http.HttpClient

@DisplayName("OIDCClient")
class OIDCClientTest {
    private val faker = Faker()
    private lateinit var httpClient: HttpClient
    private lateinit var oidcProperties: OIDCProperties
    private lateinit var testClient: TestOIDCClient

    @BeforeEach
    fun setUp() {
        httpClient = mockk()
        oidcProperties = mockk()
        testClient = TestOIDCClient(httpClient, oidcProperties)
    }

    @Nested
    @DisplayName("OIDC 토큰 교환")
    inner class GetOIDCToken {
        @Test
        @DisplayName("정상적인 authorization code로 토큰 교환 성공")
        fun `get oidc token when authorization code valid expect tokens returned`() {
            val authorizationCode = faker.internet().password()
            val expectedTokens = OIDCTestHelper.createOIDCTokens()
            testClient.mockTokens = expectedTokens

            val result = runBlocking { testClient.getOIDCToken(authorizationCode) }

            assertThat(result).isEqualTo(expectedTokens)
        }

        @Test
        @DisplayName("토큰 교환 실패 시 OIDCTokenExchangeFailedException 발생")
        fun `get oidc token when exchange fails expect throws token exchange failed`() {
            val authorizationCode = faker.internet().password()
            testClient.shouldThrowException = true

            assertThatThrownBy {
                runBlocking { testClient.getOIDCToken(authorizationCode) }
            }.isInstanceOf(OIDCTokenExchangeFailedException::class.java)
        }
    }

    private class TestOIDCClient(
        httpClient: HttpClient,
        oidcProperties: OIDCProperties,
    ) : AbstractOIDCClient(httpClient, oidcProperties) {
        var shouldThrowException = false
        var mockTokens: OIDCTokens? = null

        override suspend fun doGetOIDCToken(authorizationCode: String): OIDCTokens {
            if (shouldThrowException) {
                throw RuntimeException("Test exception")
            }
            return mockTokens ?: OIDCTestHelper.createOIDCTokens(
                accessToken = "test-access-token",
                refreshToken = "test-refresh-token",
                idToken = "test-id-token",
                expiresIn = 3600L,
            )
        }
    }
}
