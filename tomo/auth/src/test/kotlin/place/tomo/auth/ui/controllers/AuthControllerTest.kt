package place.tomo.auth.ui.controllers

import com.fasterxml.jackson.databind.ObjectMapper
import io.mockk.Runs
import io.mockk.every
import io.mockk.just
import org.assertj.core.api.Assertions.assertThat
import org.hamcrest.Matchers.equalTo
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.context.ApplicationContext
import org.springframework.context.annotation.Import
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import place.tomo.auth.application.requests.EmailPasswordAuthenticateRequest
import place.tomo.auth.application.requests.SignUpRequest
import place.tomo.auth.application.responses.LoginResponse
import place.tomo.auth.application.services.AuthApplicationService
import place.tomo.auth.domain.exception.AuthenticationFailedException
import place.tomo.auth.ui.requests.LoginRequestBody
import place.tomo.auth.ui.requests.SignUpRequestBody
import place.tomo.common.exception.GlobalExceptionHandler
import place.tomo.common.test.security.TestSecurityHelper

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
        private val authService: AuthApplicationService,
        private val objectMapper: ObjectMapper,
    ) {
        @Nested
        @DisplayName("이메일/비밀번호 회원 가입")
        inner class SignUp {
            @Test
            @DisplayName("유효한 이메일/비밀번호로 회원 가입 성공 시 200 OK를 반환한다")
            fun `signup when valid email and password expect 200 ok`() {
                val email = "user@example.com"
                val password = "StrongPassword1@"
                val name = "example"
                every { authService.signUp(SignUpRequest(email, password, name)) } just Runs

                mockMvc
                    .perform(
                        post("/api/auth/signup")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(SignUpRequestBody(email, password, name))),
                    ).andExpect(status().isOk)
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
            @DisplayName("유효하지 않은 이메일로 요청한 경우 400 Bad Request를 반환한다")
            fun `signup when invalid email expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/auth/signup")
                            .contentType(
                                MediaType.APPLICATION_JSON,
                            ).content("{\"email\": \"invalid email\", \"password\": \"secret\", \"name\": \"test\"}"),
                    ).andExpect(status().isBadRequest)
            }

            @Test
            @DisplayName("이메일 필드를 빈 문자열로 요청한 경우 400 Bad Request를 반환한다")
            fun `signup when blank email expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/auth/signup")
                            .contentType(
                                MediaType.APPLICATION_JSON,
                            ).content("{\"email\": \"\", \"password\": \"secret\", \"name\": \"test\"}"),
                    ).andExpect(status().isBadRequest)
            }

            @Test
            @DisplayName("이메일 필드를 254자 이상으로 요청한 경우 400 Bad Request를 반환한다")
            fun `signup when email longer than 254 expect 400 bad request`() {
                val longLocalPart = "a".repeat(64)
                val longDomain = "b".repeat(63) + "." + "c".repeat(63) + "." + "c".repeat(63)
                val longEmail = "$longLocalPart@$longDomain"

                mockMvc
                    .perform(
                        post("/api/auth/signup")
                            .contentType(
                                MediaType.APPLICATION_JSON,
                            ).content("{\"email\": \"$longEmail\", \"password\": \"secret\", \"name\": \"test\"}"),
                    ).andExpect(status().isBadRequest)
            }
        }

        @Nested
        @DisplayName("이메일/비밀번호 로그인")
        inner class Login {
            @Test
            @DisplayName("유효한 이메일/비밀번호로 로그인 성공 시 200 OK를 반환한다")
            fun `login when credentials valid expect 200 ok`() {
                val body = LoginRequestBody(email = "user@example.com", password = "StrongPassword1@")
                every { authService.authenticate(EmailPasswordAuthenticateRequest(body.email, body.password)) } returns
                    LoginResponse(token = "access-token", refreshToken = "refresh-token")

                mockMvc
                    .perform(
                        post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(body)),
                    ).andExpect(status().isOk)
                    .andExpect(jsonPath("$.token", equalTo("access-token")))
                    .andExpect(jsonPath("$.refreshToken", equalTo("refresh-token")))
            }

            @Test
            @DisplayName("잘못된 이메일/비밀번호로 로그인 실패 시 401 Unauthorized를 반환한다")
            fun `login when authentication fails expect 401 unauthorized`() {
                val body = LoginRequestBody(email = "user@example.com", password = "WrongPassword!2")
                every { authService.authenticate(EmailPasswordAuthenticateRequest(body.email, body.password)) } throws
                    AuthenticationFailedException()

                mockMvc
                    .perform(
                        post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(body)),
                    ).andExpect(status().isUnauthorized)
                    .andExpect(jsonPath("$.status", equalTo(401)))
            }

            @Test
            @DisplayName("요청 바디가 누락된 경우 400 Bad Request를 반환한다")
            fun `login when body missing expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{}"),
                    ).andExpect(status().isBadRequest)
            }

            @Test
            @DisplayName("유효하지 않은 이메일로 요청한 경우 400 Bad Request를 반환한다")
            fun `login when invalid email expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/auth/login")
                            .contentType(
                                MediaType.APPLICATION_JSON,
                            ).content("{\"email\": \"invalid email\", \"password\": \"secret\"}"),
                    ).andExpect(status().isBadRequest)
            }

            @Test
            @DisplayName("이메일 필드를 빈 문자열로 요청한 경우 400 Bad Request를 반환한다")
            fun `login when blank email expect 400 bad request`() {
                mockMvc
                    .perform(
                        post("/api/auth/login")
                            .contentType(
                                MediaType.APPLICATION_JSON,
                            ).content("{\"email\": \"\", \"password\": \"secret\"}"),
                    ).andExpect(status().isBadRequest)
            }

            @Test
            @DisplayName("이메일 필드를 254자 이상으로 요청한 경우 400 Bad Request를 반환한다")
            fun `login when email longer than 254 expect 400 bad request`() {
                val longLocalPart = "a".repeat(64)
                val longDomain = "b".repeat(63) + "." + "c".repeat(63) + "." + "c".repeat(63)
                val longEmail = "$longLocalPart@$longDomain"

                mockMvc
                    .perform(
                        post("/api/auth/login")
                            .contentType(
                                MediaType.APPLICATION_JSON,
                            ).content("{\"email\": \"$longEmail\", \"password\": \"secret\"}"),
                    ).andExpect(status().isBadRequest)
            }
        }
    }
