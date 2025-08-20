package place.tomo.infra.config.security

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.core.AuthenticationException
import java.io.PrintWriter
import java.io.StringWriter

@DisplayName("CustomAuthenticationEntryPoint")
class CustomAuthenticationEntryPointTest {
    private lateinit var request: HttpServletRequest
    private lateinit var response: HttpServletResponse
    private lateinit var customAuthenticationEntryPoint: CustomAuthenticationEntryPoint
    private lateinit var stringWriter: StringWriter
    private lateinit var printWriter: PrintWriter

    @BeforeEach
    fun setUp() {
        request = mockk()
        response = mockk(relaxed = true)
        customAuthenticationEntryPoint = CustomAuthenticationEntryPoint()
        stringWriter = StringWriter()
        printWriter = PrintWriter(stringWriter)

        every { response.writer } returns printWriter
    }

    @Nested
    @DisplayName("commence")
    inner class Commence {
        @Test
        @DisplayName("인증 실패 시 401 상태코드 반환")
        fun `commence when authentication fails expect 401 status code`() {
            val authException = BadCredentialsException("Invalid credentials")

            customAuthenticationEntryPoint.commence(request, response, authException)

            verify { response.contentType = "application/json" }
            verify { response.status = HttpStatus.UNAUTHORIZED.value() }
            val responseBody = stringWriter.toString()
            assertThat(responseBody).contains("\"status\":401")
            assertThat(responseBody).contains("\"message\":\"Invalid credentials\"")
        }

        @Test
        @DisplayName("메시지가 null일 때 기본 메시지 사용")
        fun `commence when message is null expect default message`() {
            val authException = object : AuthenticationException(null) {}

            customAuthenticationEntryPoint.commence(request, response, authException)

            val responseBody = stringWriter.toString()
            assertThat(responseBody).contains("\"message\":\"Unauthorized\"")
        }

        @Test
        @DisplayName("메시지에 따옴표가 있을 때 sanitization 처리")
        fun `commence when message contains quotes expect sanitization`() {
            val authException = BadCredentialsException("Invalid \"credentials\" with quotes")

            customAuthenticationEntryPoint.commence(request, response, authException)

            val responseBody = stringWriter.toString()
            assertThat(responseBody).contains("\"message\":\"Invalid 'credentials' with quotes\"")
            assertThat(responseBody).doesNotContain("\"Invalid \"credentials\"")
        }

        @Test
        @DisplayName("빈 메시지일 때 기본 메시지 사용")
        fun `handle when message is empty expect default message`() {
            val accessDeniedException = BadCredentialsException("")

            customAuthenticationEntryPoint.commence(request, response, accessDeniedException)

            val responseBody = stringWriter.toString()
            assertThat(responseBody).contains("\"message\":\"Unauthorized\"")
        }
    }
}
