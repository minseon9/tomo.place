package place.tomo.infra.config.security

import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.context.annotation.Primary
import org.springframework.http.HttpStatus
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.web.access.AccessDeniedHandler

@Primary
class CustomAccessDeniedHandler : AccessDeniedHandler {
    override fun handle(
        request: HttpServletRequest,
        response: HttpServletResponse,
        accessDeniedException: AccessDeniedException,
    ) {
        response.status = HttpStatus.FORBIDDEN.value()
        response.contentType = "application/json"

        val message = if (accessDeniedException.message?.isNotEmpty() == true) accessDeniedException.message!! else "Forbidden"
        val sanitized = message.replace('"', '\'')
        val body = "{\"status\":403,\"message\":\"$sanitized\"}"
        response.writer.write(body)
    }
}
