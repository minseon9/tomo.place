package place.tomo.auth.ui.controllers

import com.fasterxml.jackson.databind.ObjectMapper
import io.mockk.every
import org.hamcrest.Matchers.equalTo
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
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.header
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.responses.LoginResponse
import place.tomo.auth.application.services.OIDCApplicationService
import place.tomo.auth.ui.requests.SignupRequestBody
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
class AuthControllerTest
    @Autowired
    constructor(
        private val mockMvc: MockMvc,
        private val oidcAuthService: OIDCApplicationService,
        private val objectMapper: ObjectMapper,
    ) {
        @Nested
        @DisplayName("OIDC 회원가입/로그인 통합")
        inner class OIDCSignup {
            @Test
            @DisplayName("유효한 OIDC 인증 코드로 회원가입/로그인 성공 시 200 OK를 반환한다")
            fun `signup when valid authorization code expect 200 ok`() {
                val provider = OIDCProviderType.GOOGLE
                val authorizationCode = "valid code"
                val mockedResponse =
                    LoginResponse(
                        accessToken = "access-token",
                        accessTokenExpiresAt = 1000L,
                        refreshToken = "refresh-token",
                        refreshTokenExpiresAt = 1000L,
                    )
                every { oidcAuthService.signUp(OIDCSignUpRequest(provider, authorizationCode)) } returns mockedResponse

                mockMvc
                    .perform(
                        post("/api/auth/signup")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(SignupRequestBody(provider, authorizationCode))),
                    ).andExpect(status().isOk)
                    .andExpect(header().doesNotExist("Set-Cookie"))
                    .andExpect(jsonPath("$.token", equalTo(mockedResponse.accessToken)))
                    .andExpect(jsonPath("$.tokenExpiresAt", equalTo(mockedResponse.accessTokenExpiresAt)))
                    .andExpect(jsonPath("$.refreshToken", equalTo(mockedResponse.refreshToken)))
                    .andExpect(jsonPath("$.refreshTokenExpiresAt", equalTo(mockedResponse.refreshTokenExpiresAt)))
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
    }
