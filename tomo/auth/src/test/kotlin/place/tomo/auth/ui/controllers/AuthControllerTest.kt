package place.tomo.auth.ui.controllers

import com.fasterxml.jackson.databind.ObjectMapper
import io.mockk.every
import net.datafaker.Faker
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.content
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.header
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.requests.RefreshTokenRequest
import place.tomo.auth.application.responses.IssueTokenResponse
import place.tomo.auth.application.services.AuthenticationApplicationService
import place.tomo.auth.domain.exception.InvalidRefreshTokenException
import place.tomo.auth.ui.requests.RefreshTokenRequestBody
import place.tomo.auth.ui.requests.SignupRequestBody
import place.tomo.common.test.security.TestSecurityUtils
import place.tomo.contract.constant.OIDCProviderType

@WebMvcTest(
    controllers = [AuthController::class],
    excludeAutoConfiguration = [
        org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration::class,
        org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration::class,
        org.springframework.boot.autoconfigure.web.reactive.WebFluxAutoConfiguration::class,
    ],
)
@ContextConfiguration(classes = [AuthControllerTestConfig::class])
@ActiveProfiles("test")
@DisplayName("AuthController")
class AuthControllerTest {
    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var objectMapper: ObjectMapper

    @Autowired
    private lateinit var authenticationApplicationService: AuthenticationApplicationService

    private val faker = Faker()

    @Nested
    @DisplayName("OIDC 회원가입/로그인 통합")
    inner class OIDCSignup {
        @Test
        @DisplayName("유효한 OIDC 인증 코드로 회원가입/로그인 성공 시 200 OK를 반환한다")
        fun `signup when valid authorization code expect 200 ok`() {
            val provider = OIDCProviderType.GOOGLE
            val authorizationCode = faker.internet().password()
            val mockedResponse =
                IssueTokenResponse(
                    accessToken = faker.internet().password(),
                    refreshToken = faker.internet().password(),
                    accessTokenExpiresAt = System.currentTimeMillis() + 3600000,
                    refreshTokenExpiresAt = System.currentTimeMillis() + 86400000,
                )

            every {
                authenticationApplicationService.signUp(OIDCSignUpRequest(provider, authorizationCode))
            } returns mockedResponse

            mockMvc
                .perform(
                    post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(SignupRequestBody(provider, authorizationCode))),
                ).andExpect(status().isOk)
                .andExpect(header().doesNotExist("Set-Cookie"))
                .andExpect(content().json(objectMapper.writeValueAsString(mockedResponse)))
        }

        @Test
        @DisplayName("요청 바디가 누락된 경우 400 Bad Request를 반환한다")
        fun `signup when body missing expect 400 bad request`() {
            mockMvc
                .perform(
                    post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"),
                ).andExpect(status().isBadRequest)
        }

        @Test
        @DisplayName("권한 코드가 빈 문자열인 경우 400 Bad Request를 반환한다")
        fun `signup when blank authentication code expect 400 bad request`() {
            mockMvc
                .perform(
                    post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"provider\": \"${OIDCProviderType.GOOGLE}\", \"authenticationCode\": \"\"}"),
                ).andExpect(status().isBadRequest)
        }

        @Test
        @DisplayName("지원하지 않는 provider인 경우 400 Bad Request를 반환한다")
        fun `signup when invalid provider expect 400 bad request`() {
            mockMvc
                .perform(
                    post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"provider\": \"not supported provider\", \"authenticationCode\": \"valid code\"}"),
                ).andExpect(status().isBadRequest)
        }
    }

    @Nested
    @DisplayName("Refresh Token API")
    inner class RefreshTokenAPI {
        @Test
        @DisplayName("유효한 refresh token으로 요청 시 새로운 토큰을 반환한다")
        fun `refresh token when valid expect new tokens returned`() {
            val userEmail = faker.internet().emailAddress()
            val refreshToken = faker.internet().password()
            val request = RefreshTokenRequestBody(refreshToken)
            val mockedResponse =
                IssueTokenResponse(
                    accessToken = faker.internet().password(),
                    refreshToken = faker.internet().password(),
                    accessTokenExpiresAt = System.currentTimeMillis() + 3600000,
                    refreshTokenExpiresAt = System.currentTimeMillis() + 86400000,
                )
            every {
                authenticationApplicationService.refreshToken(RefreshTokenRequest(userEmail, refreshToken))
            } returns mockedResponse

            mockMvc
                .perform(
                    post("/api/auth/refresh")
                        .with(TestSecurityUtils.withUser(userEmail))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)),
                ).andExpect(status().isOk)
                .andExpect(header().doesNotExist("Set-Cookie"))
                .andExpect(content().json(objectMapper.writeValueAsString(mockedResponse)))
        }

        @Test
        @DisplayName("빈 refresh token으로 요청 시 400 Bad Request를 반환한다")
        fun `refresh token when empty expect 400 bad request`() {
            val request = RefreshTokenRequestBody("")

            mockMvc
                .perform(
                    post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)),
                ).andExpect(status().isBadRequest)
        }

        @Test
        @DisplayName("유효하지 않은 refresh token으로 요청 시 403 Bad Request를 반환한다")
        fun `refresh token when invalud expect 403 bad request`() {
            val userEmail = faker.internet().emailAddress()
            val refreshToken = "invalid refresh token"
            val request = RefreshTokenRequestBody(refreshToken)

            every {
                authenticationApplicationService.refreshToken(RefreshTokenRequest(userEmail, refreshToken))
            } throws InvalidRefreshTokenException("유효하지 않은 토큰입니다.")

            mockMvc
                .perform(
                    post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)),
                ).andExpect(status().isUnauthorized)
        }

        @Test
        @DisplayName("refresh token이 없는 요청 시 400 Bad Request를 반환한다")
        fun `refresh token when missing expect 400 bad request`() {
            val request = mapOf<String, String>()

            mockMvc
                .perform(
                    post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)),
                ).andExpect(status().isBadRequest)
        }
    }
}
