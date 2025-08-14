package place.tomo.auth.infra.config.security

import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.http.HttpStatus
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.web.access.AccessDeniedHandler

class JsonAccessDeniedHandler : AccessDeniedHandler {
    override fun handle(
        request: HttpServletRequest,
        response: HttpServletResponse,
        accessDeniedException: AccessDeniedException,
    ) {
        response.status = HttpStatus.FORBIDDEN.value()
        response.contentType = "application/json"
        val message = accessDeniedException.message ?: "Forbidden"
        val sanitized = message.replace('"', '\'')
        val body = "{\"status\":403,\"message\":\"$sanitized\"}"
        response.writer.write(body)
    }
}
