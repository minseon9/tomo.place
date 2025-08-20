package place.tomo.auth.domain.services

import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("JwtTokenProvider")
class JwtTokenProviderTest {
    private val faker: Faker = Faker()

    private val provider: JwtTokenProvider = initJwtTokenProvider()

    fun initJwtTokenProvider(
        accessTtlSeconds: Long = 604800L,
        refreshTtlSeconds: Long = 31536000L,
    ): JwtTokenProvider =
        JwtTokenProvider(
            secret = faker.random().hex(64),
            issuer = faker.name().fullName(),
            accessTtlSeconds = accessTtlSeconds,
            refreshTtlSeconds = refreshTtlSeconds,
        )

    @Nested
    @DisplayName("토큰 발급")
    inner class IssueTokens {
        @Test
        @DisplayName("주어진 사용자 이메일로 서명된 JWT Access/Refresh 토큰을 발급한다")
        fun `issue access and refresh token when subject provided expect signed jwt generated`() {
            val email = faker.internet().emailAddress()
            val access = provider.issueAccessToken(email)
            val refresh = provider.issueRefreshToken(email)

            assertThat(access).isNotBlank()
            assertThat(refresh).isNotBlank()
            assertThat(provider.validateToken(access)).isTrue()
            assertThat(provider.validateToken(refresh)).isTrue()
        }
    }

    @Nested
    @DisplayName("토큰 검증 및 파싱")
    inner class ValidateAndParse {
        @Test
        @DisplayName("유효한 토큰 검증 시 true를 반환한다")
        fun `validate token when token valid expect true returned`() {
            val token = provider.issueAccessToken("user@example.com")

            assertThat(provider.validateToken(token)).isTrue()
        }

        @Test
        @DisplayName("손상되거나 유효하지 않은 토큰 검증 시 false를 반환한다")
        fun `validate token when token invalid expect false returned`() {
            val invalidToken = "invalid token"

            assertThat(provider.validateToken(invalidToken)).isFalse()
        }

        @Test
        @DisplayName("유효 기간이 지난 토큰은 검증 시 false를 반환한다")
        fun `validate token when token expired expect false returned`() {
            // 일주일 전으로 expiration을 설정
            val expiredTokenProvider = initJwtTokenProvider(accessTtlSeconds = -604800L)
            val expiredToken = expiredTokenProvider.issueAccessToken("user@example.com")

            assertThat(expiredTokenProvider.validateToken(expiredToken)).isFalse()
        }

        @Test
        @DisplayName("유효한 토큰에서 사용자 이메일(subject)을 추출한다")
        fun `get username from token when token valid expect subject returned`() {
            val token = provider.issueAccessToken("user@example.com")

            assertThat(provider.getUsernameFromToken(token)).isEqualTo("user@example.com")
        }
    }
}
