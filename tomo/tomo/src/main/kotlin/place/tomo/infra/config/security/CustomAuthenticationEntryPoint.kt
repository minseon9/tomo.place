package place.tomo.infra.config.security

import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.context.annotation.Primary
import org.springframework.http.HttpStatus
import org.springframework.security.core.AuthenticationException
import org.springframework.security.web.AuthenticationEntryPoint

@Primary
class CustomAuthenticationEntryPoint : AuthenticationEntryPoint {
    override fun commence(
        request: HttpServletRequest,
        response: HttpServletResponse,
        authException: AuthenticationException,
    ) {
        response.status = HttpStatus.UNAUTHORIZED.value()
        response.contentType = "application/json"

        val message = if (authException.message?.isNotEmpty() == true) authException.message!! else "Unauthorized"
        val sanitized = message.replace('"', '\'')
        val body = "{\"status\":401,\"message\":\"$sanitized\"}"
        response.writer.write(body)
    }
}
