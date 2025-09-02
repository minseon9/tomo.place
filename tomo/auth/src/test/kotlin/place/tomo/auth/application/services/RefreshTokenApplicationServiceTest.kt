package place.tomo.auth.application.services

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.auth.application.requests.RefreshTokenRequest
import place.tomo.auth.application.responses.RefreshTokenResponse
import place.tomo.auth.domain.dtos.JwtTokenVO
import place.tomo.auth.domain.services.JwtProvider
import place.tomo.auth.domain.services.RefreshTokenValidationService

@DisplayName("RefreshTokenApplicationService")
class RefreshTokenApplicationServiceTest {
    private val faker: Faker = Faker()
    private lateinit var refreshTokenValidationService: RefreshTokenValidationService
    private lateinit var jwtProvider: JwtProvider
    private lateinit var service: RefreshTokenApplicationService

    @BeforeEach
    fun setUp() {
        refreshTokenValidationService = mockk()
        jwtProvider = mockk()
        service = RefreshTokenApplicationService(refreshTokenValidationService, jwtProvider)
    }

    @Nested
    @DisplayName("Refresh Token 처리")
    inner class RefreshToken {
        @Test
        @DisplayName("유효한 refresh token으로 새로운 토큰을 발급한다")
        fun `refresh token when valid expect new tokens issued`() {
            val refreshToken = faker.internet().password()
            val userEmail = faker.internet().emailAddress()
            val request = RefreshTokenRequest(refreshToken)

            val newAccessToken = JwtTokenVO(
                token = faker.internet().password(),
                expiresAt = System.currentTimeMillis() + 3600000 // 1시간 후
            )
            val newRefreshToken = JwtTokenVO(
                token = faker.internet().password(),
                expiresAt = System.currentTimeMillis() + 86400000 // 24시간 후
            )

            every { refreshTokenValidationService.validateRefreshToken(refreshToken) } returns userEmail
            every { jwtProvider.issueAccessToken(userEmail) } returns newAccessToken
            every { jwtProvider.issueRefreshToken(userEmail) } returns newRefreshToken

            val result = service.refreshToken(request)

            assertThat(result.accessToken).isEqualTo(newAccessToken.token)
            assertThat(result.refreshToken).isEqualTo(newRefreshToken.token)
            assertThat(result.accessTokenExpiresAt).isEqualTo(newAccessToken.expiresAt)
            assertThat(result.refreshTokenExpiresAt).isEqualTo(newRefreshToken.expiresAt)

            verify { 
                refreshTokenValidationService.validateRefreshToken(refreshToken)
                jwtProvider.issueAccessToken(userEmail)
                jwtProvider.issueRefreshToken(userEmail)
            }
        }

        @Test
        @DisplayName("Refresh token 검증 실패 시 예외를 전파한다")
        fun `refresh token when validation fails expect exception propagated`() {
            val refreshToken = faker.internet().password()
            val request = RefreshTokenRequest(refreshToken)
            val errorMessage = "Token expired"

            every { refreshTokenValidationService.validateRefreshToken(refreshToken) } throws RuntimeException(errorMessage)

            val result = runCatching { service.refreshToken(request) }

            assertThat(result.isFailure).isTrue()
            assertThat(result.exceptionOrNull()).isInstanceOf(RuntimeException::class.java)
            assertThat(result.exceptionOrNull()?.message).isEqualTo(errorMessage)

            verify { refreshTokenValidationService.validateRefreshToken(refreshToken) }
            verify(exactly = 0) { jwtProvider.issueAccessToken(any()) }
            verify(exactly = 0) { jwtProvider.issueRefreshToken(any()) }
        }
    }
}
