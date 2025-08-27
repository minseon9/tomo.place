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
import place.tomo.auth.application.requests.OIDCAuthenticateRequest
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.responses.LoginResponse
import place.tomo.auth.application.services.OIDCApplicationService
import place.tomo.auth.domain.exception.SocialAccountNotLinkedException
import place.tomo.auth.ui.requests.OIDCLoginRequestBody
import place.tomo.auth.ui.requests.OIDCSignupRequestBody
import place.tomo.contract.constant.OIDCProviderType

@WebMvcTest(
    controllers = [OIDCController::class],
    excludeAutoConfiguration = [
        org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration::class,
        org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration::class,
        org.springframework.boot.autoconfigure.web.reactive.WebFluxAutoConfiguration::class,
    ],
)
@ContextConfiguration(classes = [AuthControllerTestConfig::class])
@ActiveProfiles("test")
@DisplayName("OIDCController")
class OIDCControllerTest
    @Autowired
    constructor(
        private val mockMvc: MockMvc,
        private val oidcAuthService: OIDCApplicationService,
        private val objectMapper: ObjectMapper,
    ) {
        @Nested
        @DisplayName("OIDC 회원 가입")
        inner class OIDCAuthentication {
            @Test
            @DisplayName("유효한 OIDC 인증 코드로 회원 가입 성공 시 200 OK를 반환한다")
            fun `signup when valid authorization code expect 200 ok`() {
                val provider = OIDCProviderType.GOOGLE
                val authorizationCode = "valid code"
                every { oidcAuthService.signUp(OIDCSignUpRequest(provider, authorizationCode)) } returns
                    LoginResponse(token = "access-token", refreshToken = "refresh-token")

                mockMvc
                    .perform(
                        post("/api/oidc/signup")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(OIDCSignupRequestBody(provider, authorizationCode))),
                    ).andExpect(status().isOk)
                    .andExpect(header().doesNotExist("Set-Cookie"))
                    .andExpect(jsonPath("$.token", equalTo("access-token")))
                    .andExpect(jsonPath("$.refreshToken", equalTo("refresh-token")))
            }

            @Test
            @DisplayName("요청 바디가 누락된 경우 400 Bad Request를 반환한다")
            fun `signup when body missing expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/oidc/signup")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{}"),
                    ).andExpect(status().isBadRequest)
            }

            @Test
            @DisplayName("권한 코드가 빈 문자열인 경우 400 Bad Request를 반환한다")
            fun `signup when blank authentication code expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/oidc/signup")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"provider\": \"${OIDCProviderType.GOOGLE}\", \"authenticationCode\": \"\"}"),
                    ).andExpect(status().isBadRequest)
            }

            @Test
            @DisplayName("지원하지 않는 provider인 경우 400 Bad Request를 반환한다")
            fun `signup when invalid provider expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/oidc/signup")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"provider\": \"not supported provider\", \"authenticationCode\": \"valid code\"}"),
                    ).andExpect(status().isBadRequest)
            }
        }

        @Nested
        @DisplayName("OIDC 로그인")
        inner class OIDCLogin {
            @Test
            @DisplayName("유효한 OIDC 인증 코드로 로그인 성공 시 200 OK를 반환한다")
            fun `login when valid authorization code expect 200 ok`() {
                val body = OIDCLoginRequestBody(provider = OIDCProviderType.GOOGLE, authorizationCode = "valid code")
                every { oidcAuthService.authenticate(OIDCAuthenticateRequest(body.provider, body.authorizationCode)) } returns
                    LoginResponse(token = "access-token", refreshToken = "refresh-token")

                mockMvc
                    .perform(
                        post("/api/oidc/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(body)),
                    ).andExpect(status().isOk)
                    .andExpect(header().doesNotExist("Set-Cookie"))
                    .andExpect(jsonPath("$.token", equalTo("access-token")))
                    .andExpect(jsonPath("$.refreshToken", equalTo("refresh-token")))
            }

            @Test
            @DisplayName("연결되지 않은 소셜 계정으로 OIDC 로그인 시 접근 거부 에러를 반환한다")
            fun `login when social account not linked expect 403 forbidden`() {
                val provider = OIDCProviderType.GOOGLE
                val authorizationCode = "unauthorized code"

                every { oidcAuthService.authenticate(OIDCAuthenticateRequest(provider, authorizationCode)) } throws
                    SocialAccountNotLinkedException(provider)

                mockMvc
                    .perform(
                        post("/api/oidc/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(
                                objectMapper.writeValueAsString(
                                    OIDCLoginRequestBody(provider, authorizationCode),
                                ),
                            ),
                    ).andExpect(status().isUnauthorized)
            }

            @Test
            @DisplayName("요청 바디가 누락된 경우 400 Bad Request를 반환한다")
            fun `login when body missing expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/oidc/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{}"),
                    ).andExpect(status().isBadRequest)
            }

            @Test
            @DisplayName("권한 코드가 빈 문자열인 경우 400 Bad Request를 반환한다")
            fun `login when blank authentication code expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/oidc/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"provider\": \"${OIDCProviderType.GOOGLE}\", \"authenticationCode\": \"\"}"),
                    ).andExpect(status().isBadRequest)
            }

            @Test
            @DisplayName("지원하지 않는 provider인 경우 400 Bad Request를 반환한다")
            fun `login when invalid provider expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/oidc/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"provider\": \"not supported provider\", \"authenticationCode\": \"valid code\"}"),
                    ).andExpect(status().isBadRequest)
            }
        }
    }
