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
import org.springframework.security.access.AccessDeniedException
import java.io.PrintWriter
import java.io.StringWriter

@DisplayName("CustomAccessDeniedHandler")
class CustomAccessDeniedHandlerTest {
    private lateinit var request: HttpServletRequest
    private lateinit var response: HttpServletResponse
    private lateinit var customAccessDeniedHandler: CustomAccessDeniedHandler
    private lateinit var stringWriter: StringWriter
    private lateinit var printWriter: PrintWriter

    @BeforeEach
    fun setUp() {
        request = mockk()
        response = mockk(relaxed = true)
        customAccessDeniedHandler = CustomAccessDeniedHandler()
        stringWriter = StringWriter()
        printWriter = PrintWriter(stringWriter)

        every { response.writer } returns printWriter
    }

    @Nested
    @DisplayName("handle")
    inner class Handle {
        @Test
        @DisplayName("접근 거부 시 403 상태코드 반환")
        fun `handle when access denied expect 403 status code`() {
            val accessDeniedException = AccessDeniedException("Access denied")

            customAccessDeniedHandler.handle(request, response, accessDeniedException)

            verify { response.contentType = "application/json" }
            verify { response.status = HttpStatus.FORBIDDEN.value() }
            val responseBody = stringWriter.toString()
            assertThat(responseBody).contains("\"status\":403")
            assertThat(responseBody).contains("\"message\":\"Access denied\"")
        }

        @Test
        @DisplayName("메시지가 null일 때 기본 메시지 사용")
        fun `handle when message is null expect default message`() {
            val accessDeniedException = AccessDeniedException(null)

            customAccessDeniedHandler.handle(request, response, accessDeniedException)

            val responseBody = stringWriter.toString()
            assertThat(responseBody).contains("\"message\":\"Forbidden\"")
        }

        @Test
        @DisplayName("메시지에 따옴표가 있을 때 sanitization 처리")
        fun `handle when message contains quotes expect sanitization`() {
            val accessDeniedException = AccessDeniedException("Access \"denied\" with quotes")

            customAccessDeniedHandler.handle(request, response, accessDeniedException)

            val responseBody = stringWriter.toString()
            assertThat(responseBody).contains("\"message\":\"Access 'denied' with quotes\"")
            assertThat(responseBody).doesNotContain("\"Access \"denied\"")
        }

        @Test
        @DisplayName("빈 메시지일 때 기본 메시지 사용")
        fun `handle when message is empty expect default message`() {
            val accessDeniedException = AccessDeniedException("")

            customAccessDeniedHandler.handle(request, response, accessDeniedException)

            val responseBody = stringWriter.toString()
            assertThat(responseBody).contains("\"message\":\"Forbidden\"")
        }
    }
}
