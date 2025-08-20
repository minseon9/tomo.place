package place.tomo.auth.domain.services.oidc

import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.test.runTest
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.auth.domain.dtos.oidc.OIDCEndpoints
import place.tomo.auth.domain.dtos.oidc.OIDCIdTokenClaims
import place.tomo.auth.domain.exception.InvalidIdTokenException
import place.tomo.auth.domain.exception.OIDCTokenExchangeFailedException
import place.tomo.auth.domain.services.oidc.discovery.OIDCMetadataResolver
import place.tomo.contract.constant.OIDCProviderType

@DisplayName("OIDCProvider")
class OIDCProviderTest {
    private val faker = Faker()
    private lateinit var oidcClient: OIDCClient
    private lateinit var metadataResolver: OIDCMetadataResolver
    private lateinit var oidcProperties: OIDCProperties
    private lateinit var testProvider: TestOIDCProvider
    private lateinit var mockProvider: OIDCProviderType

    @BeforeEach
    fun setUp() {
        oidcClient = mockk()
        metadataResolver = mockk()
        oidcProperties = mockk()
        mockProvider = mockk()
        testProvider = TestOIDCProvider(oidcClient, metadataResolver, oidcProperties, mockProvider)
    }

    @Nested
    @DisplayName("OIDC 사용자 정보 조회")
    inner class GetOIDCUserInfo {
        @Test
        @DisplayName("정상적인 authorization code로 사용자 정보 조회 성공")
        fun `get oidc user info when authorization code valid expect user info returned`() {
            val authorizationCode = faker.internet().password()
            val oidcTokens = OIDCTestHelper.createOIDCTokens()
            val endpoints = OIDCTestHelper.createEndpoints()
            val claims = OIDCTestHelper.createClaims()

            coEvery { oidcClient.getOIDCToken(authorizationCode) } returns oidcTokens
            coEvery { metadataResolver.getEndpoints(mockProvider) } returns endpoints
            every { oidcProperties.clientId } returns OIDCTestHelper.TEST_CLIENT_ID
            testProvider.mockClaims = claims

            runTest {
                val result = testProvider.getOIDCUserInfo(authorizationCode)

                assertThat(result.provider).isEqualTo(mockProvider)
                assertThat(result.socialId).isEqualTo(claims.subject)
                assertThat(result.email).isEqualTo(claims.email)
                assertThat(result.name).isEqualTo(claims.name)
                assertThat(result.profileImageUrl).isEqualTo(claims.picture)
            }
        }

        @Test
        @DisplayName("토큰 교환 실패 시 예외 전파")
        fun `get oidc user info when token exchange fails expect throws token exchange failed`() {
            val authorizationCode = faker.internet().password()
            coEvery { oidcClient.getOIDCToken(authorizationCode) } throws OIDCTokenExchangeFailedException("Token exchange failed")

            assertThatThrownBy {
                runBlocking { testProvider.getOIDCUserInfo(authorizationCode) }
            }.isInstanceOf(OIDCTokenExchangeFailedException::class.java)
        }

        @Test
        @DisplayName("ID 토큰 파싱 실패 시 예외 전파")
        fun `get oidc user info when id token parsing fails expect throws exception`() {
            val authorizationCode = faker.internet().password()
            val oidcTokens = OIDCTestHelper.createOIDCTokens()

            coEvery { oidcClient.getOIDCToken(authorizationCode) } returns oidcTokens
            testProvider.shouldThrowParsingException = true

            assertThatThrownBy {
                runBlocking { testProvider.getOIDCUserInfo(authorizationCode) }
            }.isInstanceOf(InvalidIdTokenException::class.java)
        }
    }

    @Nested
    @DisplayName("ID 토큰 검증")
    inner class ValidateIdToken {
        @Test
        @DisplayName("issuer가 일치하지 않으면 InvalidIdTokenException 발생")
        fun `get oidc user info when issuer mismatch expect throws invalid id token`() {
            val authorizationCode = faker.internet().password()
            val oidcTokens = OIDCTestHelper.createOIDCTokens()
            val endpoints = OIDCTestHelper.createEndpoints("https://correct-issuer.com")
            val claims = OIDCTestHelper.createClaims(issuer = "https://wrong-issuer.com")

            coEvery { oidcClient.getOIDCToken(authorizationCode) } returns oidcTokens
            coEvery { metadataResolver.getEndpoints(mockProvider) } returns endpoints
            testProvider.mockClaims = claims

            assertThatThrownBy {
                runBlocking { testProvider.getOIDCUserInfo(authorizationCode) }
            }.isInstanceOf(InvalidIdTokenException::class.java)
        }

        @Test
        @DisplayName("audience가 일치하지 않으면 InvalidIdTokenException 발생")
        fun `get oidc user info when audience mismatch expect throws invalid id token`() {
            val authorizationCode = faker.internet().password()
            val oidcTokens = OIDCTestHelper.createOIDCTokens()
            val endpoints = OIDCTestHelper.createEndpoints()
            val claims = OIDCTestHelper.createClaims(audiences = listOf("wrong-client-id"))

            coEvery { oidcClient.getOIDCToken(authorizationCode) } returns oidcTokens
            coEvery { metadataResolver.getEndpoints(mockProvider) } returns endpoints
            every { oidcProperties.clientId } returns "correct-client-id"
            testProvider.mockClaims = claims

            assertThatThrownBy {
                runBlocking { testProvider.getOIDCUserInfo(authorizationCode) }
            }.isInstanceOf(InvalidIdTokenException::class.java)
        }

        @Test
        @DisplayName("토큰이 만료되었으면 InvalidIdTokenException 발생")
        fun `get oidc user info when token expired expect throws invalid id token`() {
            val authorizationCode = faker.internet().password()
            val oidcTokens = OIDCTestHelper.createOIDCTokens()
            val endpoints = OIDCTestHelper.createEndpoints()
            val claims =
                OIDCTestHelper.createClaims(
                    expirationEpochSeconds = System.currentTimeMillis() / 1000 - 3600, // 만료됨
                    issuedAtEpochSeconds = System.currentTimeMillis() / 1000 - 7200,
                )

            coEvery { oidcClient.getOIDCToken(authorizationCode) } returns oidcTokens
            coEvery { metadataResolver.getEndpoints(mockProvider) } returns endpoints
            every { oidcProperties.clientId } returns OIDCTestHelper.TEST_CLIENT_ID
            testProvider.mockClaims = claims

            assertThatThrownBy {
                runBlocking { testProvider.getOIDCUserInfo(authorizationCode) }
            }.isInstanceOf(InvalidIdTokenException::class.java)
        }

        @Test
        @DisplayName("이메일이 없으면 InvalidIdTokenException 발생")
        fun `get oidc user info when email missing expect throws invalid id token`() {
            val authorizationCode = faker.internet().password()
            val oidcTokens = OIDCTestHelper.createOIDCTokens()
            val endpoints = OIDCTestHelper.createEndpoints()
            val claims = OIDCTestHelper.createClaims(email = null) // 이메일 없음

            coEvery { oidcClient.getOIDCToken(authorizationCode) } returns oidcTokens
            coEvery { metadataResolver.getEndpoints(mockProvider) } returns endpoints
            every { oidcProperties.clientId } returns OIDCTestHelper.TEST_CLIENT_ID
            testProvider.mockClaims = claims

            assertThatThrownBy {
                runBlocking { testProvider.getOIDCUserInfo(authorizationCode) }
            }.isInstanceOf(InvalidIdTokenException::class.java)
        }

        @Test
        @DisplayName("이메일이 미인증이면 InvalidIdTokenException 발생")
        fun `get oidc user info when email not verified expect throws invalid id token`() {
            val authorizationCode = faker.internet().password()
            val oidcTokens = OIDCTestHelper.createOIDCTokens()
            val endpoints = OIDCTestHelper.createEndpoints()
            val claims = OIDCTestHelper.createClaims(emailVerified = false) // 미인증

            coEvery { oidcClient.getOIDCToken(authorizationCode) } returns oidcTokens
            coEvery { metadataResolver.getEndpoints(mockProvider) } returns endpoints
            every { oidcProperties.clientId } returns OIDCTestHelper.TEST_CLIENT_ID
            testProvider.mockClaims = claims

            assertThatThrownBy {
                runBlocking { testProvider.getOIDCUserInfo(authorizationCode) }
            }.isInstanceOf(InvalidIdTokenException::class.java)
        }
    }

    // Test 구현체를 내부에 정의
    private class TestOIDCProvider(
        oidcClient: OIDCClient,
        metadataResolver: OIDCMetadataResolver,
        oidcProperties: OIDCProperties,
        providerType: OIDCProviderType,
    ) : AbstractOIDCProvider(oidcClient, metadataResolver, oidcProperties, providerType) {
        var mockClaims: OIDCIdTokenClaims? = null
        var shouldThrowParsingException = false

        override suspend fun parseIdToken(idToken: String): OIDCIdTokenClaims {
            if (shouldThrowParsingException) {
                throw InvalidIdTokenException("Test parsing exception")
            }
            return mockClaims ?: OIDCTestHelper.createClaims()
        }

        override fun validateIdToken(
            claims: OIDCIdTokenClaims,
            endpoints: OIDCEndpoints,
        ) {
            super.validateIdToken(claims, endpoints)
        }
    }
}
