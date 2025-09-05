package place.tomo.auth.domain.services.jwt

import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.JwtEncoderParameters
import place.tomo.auth.domain.dtos.JwtPropertiesDTO
import java.time.Instant

@DisplayName("JwtProvider")
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
            val subject = faker.internet().emailAddress()

            val mockJwt =
                mockk<Jwt> {
                    every { tokenValue } returns "test-access-token"
                }
            every { jwtEncoder.encode(any()) } returns mockJwt

            val issueToken = provider.issueAccessToken(subject)

            assertThat(issueToken.token).isEqualTo("test-access-token")
            assertThat(issueToken.expiresAt).isAfter(Instant.now())

            val parametersSlot = slot<JwtEncoderParameters>()
            verify { jwtEncoder.encode(capture(parametersSlot)) }

            val capturedParameters = parametersSlot.captured
            val claims = capturedParameters.claims

            assertThat(claims.getClaim<String>("iss")).isEqualTo(jwtProperties.issuer)
            assertThat(claims.getClaim<String>("sub")).isEqualTo(subject)
            assertThat(claims.getClaim<List<String>>("aud")).isEqualTo(jwtProperties.audiences)
            assertThat(claims.getClaim<Instant>("iat")).isBefore(Instant.now())
            assertThat(claims.getClaim<Instant>("exp")).isAfter(Instant.now())
        }

        @Test
        @DisplayName("주어진 사용자 이메일로 서명된 JWT Refresh 토큰을 발급한다")
        fun `issue refresh token when subject provided expect signed jwt generated`() {
            val subject = faker.internet().emailAddress()
            val mockJwt =
                mockk<Jwt> {
                    every { tokenValue } returns "test-refresh-token"
                }
            every { jwtEncoder.encode(any()) } returns mockJwt

            val refreshToken = provider.issueRefreshToken(subject)

            assertThat(refreshToken.token).isEqualTo("test-refresh-token")
            assertThat(refreshToken.expiresAt).isAfter(Instant.now())

            val parametersSlot = slot<JwtEncoderParameters>()
            verify { jwtEncoder.encode(capture(parametersSlot)) }

            val capturedParameters = parametersSlot.captured
            val claims = capturedParameters.claims

            assertThat(claims.getClaim<String>("iss")).isEqualTo(jwtProperties.issuer)
            assertThat(claims.getClaim<String>("sub")).isEqualTo(subject)
            assertThat(claims.getClaim<List<String>>("aud")).isEqualTo(jwtProperties.audiences)
            assertThat(claims.getClaim<Instant>("iat")).isBefore(Instant.now())
            assertThat(claims.getClaim<Instant>("exp")).isAfter(Instant.now())

            verify { jwtEncoder.encode(any()) }
        }
    }
}
