package place.tomo.auth.ui.controllers

import com.fasterxml.jackson.databind.ObjectMapper
import io.mockk.every
import io.mockk.mockk
import net.datafaker.Faker
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import place.tomo.auth.application.requests.RefreshTokenRequest
import place.tomo.auth.application.responses.RefreshTokenResponse
import place.tomo.auth.application.services.OIDCApplicationService
import place.tomo.auth.application.services.RefreshTokenApplicationService
import place.tomo.auth.ui.requests.SignupRequestBody

@WebMvcTest(AuthController::class)
@DisplayName("AuthController")
class AuthControllerTest {
    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var objectMapper: ObjectMapper

    @MockBean
    private lateinit var oidcAuthService: OIDCApplicationService

    @MockBean
    private lateinit var refreshTokenService: RefreshTokenApplicationService

    private val faker = Faker()

    @Nested
    @DisplayName("Refresh Token API")
    inner class RefreshTokenAPI {
        @Test
        @DisplayName("유효한 refresh token으로 요청 시 새로운 토큰을 반환한다")
        fun `refresh token when valid expect new tokens returned`() {
            val refreshToken = faker.internet().password()
            val newAccessToken = faker.internet().password()
            val newRefreshToken = faker.internet().password()
            val accessTokenExpiresAt = System.currentTimeMillis() + 3600000
            val refreshTokenExpiresAt = System.currentTimeMillis() + 86400000

            val request = RefreshTokenRequest(refreshToken)
            val response = RefreshTokenResponse(
                accessToken = newAccessToken,
                refreshToken = newRefreshToken,
                accessTokenExpiresAt = accessTokenExpiresAt,
                refreshTokenExpiresAt = refreshTokenExpiresAt
            )

            every { refreshTokenService.refreshToken(any()) } returns response

            mockMvc.perform(
                post("/api/auth/refresh")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request))
            )
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.accessToken").value(newAccessToken))
                .andExpect(jsonPath("$.refreshToken").value(newRefreshToken))
                .andExpect(jsonPath("$.accessTokenExpiresAt").value(accessTokenExpiresAt))
                .andExpect(jsonPath("$.refreshTokenExpiresAt").value(refreshTokenExpiresAt))
        }

        @Test
        @DisplayName("빈 refresh token으로 요청 시 400 Bad Request를 반환한다")
        fun `refresh token when empty expect 400 bad request`() {
            val request = RefreshTokenRequest("")

            mockMvc.perform(
                post("/api/auth/refresh")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request))
            )
                .andExpect(status().isBadRequest)
        }

        @Test
        @DisplayName("refresh token이 없는 요청 시 400 Bad Request를 반환한다")
        fun `refresh token when missing expect 400 bad request`() {
            val request = mapOf<String, String>()

            mockMvc.perform(
                post("/api/auth/refresh")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request))
            )
                .andExpect(status().isBadRequest)
        }
    }
}
