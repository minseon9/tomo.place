package place.tomo.auth.domain.services.jwt

import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkObject
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatNoException
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtException
import place.tomo.auth.domain.exception.InvalidRefreshTokenException
import java.time.Instant

@DisplayName("RefreshTokenValidationService")
class JwtValidatorTest {
    private val faker: Faker = Faker()
    private lateinit var jwtDecoder: JwtDecoder
    private lateinit var service: JwtValidator

    @BeforeEach
    fun setUp() {
        jwtDecoder = mockk()
        service = JwtValidator(jwtDecoder)
    }

    @Nested
    @DisplayName("Refresh Token 검증")
    inner class ValidateRefreshToken {
        @Test
        @DisplayName("유효한 refresh token으로 검증 시 사용자 이메일을 반환한다")
        fun `validate refresh token when valid expect user email returned`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()

            val mockJwt =
                mockk<Jwt> {
                    every { subject } returns userEmail
                    every { expiresAt } returns Instant.now().plusSeconds(3600)
                }
            every { jwtDecoder.decode(refreshToken) } returns mockJwt

            assertDoesNotThrow { service.validateRefreshToken(userEmail, refreshToken) }
        }

        @Test
        @DisplayName("만료된 refresh token으로 검증 시 예외를 던진다")
        fun `validate refresh token when expired expect exception thrown`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()

            val mockJwt =
                mockk<Jwt> {
                    every { subject } returns userEmail
                    every { expiresAt } returns Instant.now().minusSeconds(3600)
                }
            every { jwtDecoder.decode(refreshToken) } returns mockJwt

            assertThatThrownBy { service.validateRefreshToken(userEmail, refreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
        }

        @Test
        @DisplayName("subject가 없는 refresh token으로 검증 시 예외를 던진다")
        fun `validate refresh token when missing subject expect exception thrown`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()

            val mockJwt =
                mockk<Jwt> {
                    every { subject } returns null
                    every { expiresAt } returns Instant.now().plusSeconds(3600)
                }
            every { jwtDecoder.decode(refreshToken) } returns mockJwt

            assertThatThrownBy { service.validateRefreshToken(userEmail, refreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
        }

        @Test
        @DisplayName("빈 subject를 가진 refresh token으로 검증 시 예외를 던진다")
        fun `validate refresh token when empty subject expect exception thrown`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()

            val mockJwt =
                mockk<Jwt> {
                    every { subject } returns ""
                    every { expiresAt } returns Instant.now().plusSeconds(3600)
                }
            every { jwtDecoder.decode(refreshToken) } returns mockJwt

            assertThatThrownBy { service.validateRefreshToken(userEmail, refreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
        }

        @Test
        @DisplayName("JWT 디코딩 실패 시 예외를 던진다")
        fun `validate refresh token when jwt decoding fails expect exception thrown`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()
            val errorMessage = "Invalid JWT format"

            every { jwtDecoder.decode(refreshToken) } throws JwtException(errorMessage)

            assertThatThrownBy { service.validateRefreshToken(userEmail, refreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
        }
    }
}
