package place.tomo.auth.domain.services.jwt

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
import place.tomo.auth.domain.constants.JwtType
import place.tomo.auth.domain.exception.InvalidRefreshTokenException

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
                    every { getClaim<JwtType>("type") } returns JwtType.REFRESH
                }
            every { jwtDecoder.decode(refreshToken) } returns mockJwt

            val result = service.validateRefreshToken(refreshToken)
            assertThat(result).isEqualTo(userEmail)
        }

        // NOTE: JwtDecoder의 validation 동작들은 JwtConfigTest에서 검증힙니다.
        @Test
        @DisplayName("invalid refresh token을 decode 시 예외를 던진다")
        fun `decode refresh token when invalid expect exception thrown`() {
            val refreshToken = "invalid refresh token"

            every { jwtDecoder.decode(refreshToken) } throws JwtException("유효하지 않은 토큰입니다.")

            assertThatThrownBy { service.validateRefreshToken(refreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
        }

        @Test
        @DisplayName("refresh type이 아닌 경우 예외를 던진다")
        fun `decode refresh token when type is not REFRESH expect exception thrown`() {
            val notRefreshToken = "not refresh token"

            val mockJwt =
                mockk<Jwt> {
                    every { getClaim<JwtType>("type") } returns JwtType.ACCESS
                }
            every { jwtDecoder.decode(notRefreshToken) } returns mockJwt

            assertThatThrownBy { service.validateRefreshToken(notRefreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
                .message()
        }

        @Test
        @DisplayName("type claim이 null인 경우 예외를 던진다")
        fun `decode refresh token when type is null expect exception thrown`() {
            val typeNullRefreshToken = "type null refresh token"

            val mockJwt =
                mockk<Jwt> {
                    every { getClaim<JwtType>("type") } returns null
                }
            every { jwtDecoder.decode(typeNullRefreshToken) } returns mockJwt

            assertThatThrownBy { service.validateRefreshToken(typeNullRefreshToken) }
                .isInstanceOf(InvalidRefreshTokenException::class.java)
                .message()
        }
    }
}
