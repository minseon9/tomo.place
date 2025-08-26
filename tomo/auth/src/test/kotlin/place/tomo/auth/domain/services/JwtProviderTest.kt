package place.tomo.auth.domain.services

import io.mockk.mockk
import io.mockk.verify
import net.datafaker.Faker
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.security.oauth2.jwt.JwtEncoder

@DisplayName("JwtTokenProvider")
class JwtProviderTest {
    private val faker: Faker = Faker()
    private val jwtEncoder: JwtEncoder = mockk(relaxed = true)
    private val provider: JwtProvider = initJwtTokenProvider()

    fun initJwtTokenProvider(
        accessTtlSeconds: Long = 604800L,
        refreshTtlSeconds: Long = 31536000L,
    ): JwtProvider {
        val audiences: List<String> =
            faker
                .collection<String>({ faker.internet().url() })
                .len(3)
                .generate<List<String>>()

        return JwtProvider(
            issuer = faker.name().fullName(),
            audiences = audiences,
            accessTtlSeconds = accessTtlSeconds,
            refreshTtlSeconds = refreshTtlSeconds,
            jwtEncoder = jwtEncoder,
        )
    }

    @Nested
    @DisplayName("토큰 발급")
    inner class IssueTokens {
        @Test
        @DisplayName("주어진 사용자 이메일로 서명된 JWT Access 토큰을 발급한다")
        fun `issue access token when subject provided expect signed jwt generated`() {
            val email = faker.internet().emailAddress()
            provider.issueAccessToken(email)

            verify { jwtEncoder.encode(any()) }
        }

        @Test
        @DisplayName("주어진 사용자 이메일로 서명된 JWT Refresh 토큰을 발급한다")
        fun `issue refresh token when subject provided expect signed jwt generated`() {
            val email = faker.internet().emailAddress()
            provider.issueRefreshToken(email)

            verify { jwtEncoder.encode(any()) }
        }
    }
}
