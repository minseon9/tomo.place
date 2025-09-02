package place.tomo.auth.domain.services

import io.mockk.every
import io.mockk.mockk
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtException
import place.tomo.auth.domain.exception.InvalidRefreshTokenException
import java.time.Instant

@DisplayName("RefreshTokenValidationService")
class RefreshTokenValidationServiceTest {
    private val faker: Faker = Faker()
    private lateinit var jwtDecoder: JwtDecoder
    private lateinit var service: RefreshTokenValidationService

    @BeforeEach
    fun setUp() {
        jwtDecoder = mockk()
        service = RefreshTokenValidationService(jwtDecoder)
    }

    @Nested
    @DisplayName("Refresh Token 검증")
    inner class ValidateRefreshToken {
        @Test
        @DisplayName("유효한 refresh token으로 검증 시 사용자 이메일을 반환한다")
        fun `validate refresh token when valid expect user email returned`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()
            val expiresAt = Instant.now().plusSeconds(3600)

            val mockJwt = mockk<Jwt> {
                every { subject } returns userEmail
                every { expiresAt } returns expiresAt
            }
            every { jwtDecoder.decode(refreshToken) } returns mockJwt

            val result = service.validateRefreshToken(refreshToken)

            assertThat(result).isEqualTo(userEmail)
        }

        @Test
        @DisplayName("만료된 refresh token으로 검증 시 예외를 던진다")
        fun `validate refresh token when expired expect exception thrown`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()
            val expiresAt = Instant.now().minusSeconds(3600) // 과거 시간

            val mockJwt = mockk<Jwt> {
                every { subject } returns userEmail
                every { expiresAt } returns expiresAt
            }
            every { jwtDecoder.decode(refreshToken) } returns mockJwt

            assertThatThrownBy { service.validateRefreshToken(refreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
                .hasMessageContaining("Refresh token has expired")
        }

        @Test
        @DisplayName("subject가 없는 refresh token으로 검증 시 예외를 던진다")
        fun `validate refresh token when missing subject expect exception thrown`() {
            val refreshToken = faker.internet().password()
            val expiresAt = Instant.now().plusSeconds(3600)

            val mockJwt = mockk<Jwt> {
                every { subject } returns null
                every { expiresAt } returns expiresAt
            }
            every { jwtDecoder.decode(refreshToken) } returns mockJwt

            assertThatThrownBy { service.validateRefreshToken(refreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
                .hasMessageContaining("Refresh token missing subject")
        }

        @Test
        @DisplayName("빈 subject를 가진 refresh token으로 검증 시 예외를 던진다")
        fun `validate refresh token when empty subject expect exception thrown`() {
            val refreshToken = faker.internet().password()
            val expiresAt = Instant.now().plusSeconds(3600)

            val mockJwt = mockk<Jwt> {
                every { subject } returns ""
                every { expiresAt } returns expiresAt
            }
            every { jwtDecoder.decode(refreshToken) } returns mockJwt

            assertThatThrownBy { service.validateRefreshToken(refreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
                .hasMessageContaining("Refresh token missing subject")
        }

        @Test
        @DisplayName("JWT 디코딩 실패 시 예외를 던진다")
        fun `validate refresh token when jwt decoding fails expect exception thrown`() {
            val refreshToken = faker.internet().password()
            val errorMessage = "Invalid JWT format"
            
            every { jwtDecoder.decode(refreshToken) } throws JwtException(errorMessage)

            assertThatThrownBy { service.validateRefreshToken(refreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
                .hasMessageContaining("Invalid refresh token: $errorMessage")
        }
    }
}
