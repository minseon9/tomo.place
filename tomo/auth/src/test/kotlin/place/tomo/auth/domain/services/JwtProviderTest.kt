package place.tomo.auth.domain.services

import io.mockk.mockk
import io.mockk.verify
import net.datafaker.Faker
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.security.oauth2.jwt.JwtEncoder
import place.tomo.auth.domain.dtos.JwtPropertiesDTO

@DisplayName("JwtTokenProvider")
class JwtProviderTest {
    private val faker: Faker = Faker()
    private val jwtEncoder: JwtEncoder = mockk(relaxed = true)
    private val jwtProperties: JwtPropertiesDTO =
        JwtPropertiesDTO(
            issuer = faker.name().fullName(),
            audiences =
                faker
                    .collection<String>({ faker.internet().url() })
                    .len(3)
                    .generate<List<String>>(),
            accessTtlSeconds = 604800L,
            refreshTtlSeconds = 31536000L,
        )
    private val provider: JwtProvider = JwtProvider(jwtProperties, jwtEncoder)

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
