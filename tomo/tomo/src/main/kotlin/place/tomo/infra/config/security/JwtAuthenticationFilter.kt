package place.tomo.infra.config.security

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.web.filter.OncePerRequestFilter
import place.tomo.auth.domain.services.JwtTokenProvider

class JwtAuthenticationFilter(
    private val jwtTokenProvider: JwtTokenProvider,
    private val userDetailsService: UserDetailsService,
) : OncePerRequestFilter() {
    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain,
    ) {
        try {
            val token = extractTokenFromRequest(request)

            if (token?.isNotEmpty() == true && jwtTokenProvider.validateToken(token)) {
                val username = jwtTokenProvider.getUsernameFromToken(token)
                val userDetails = userDetailsService.loadUserByUsername(username)

                val authentication =
                    UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.authorities,
                    )

                SecurityContextHolder.getContext().authentication = authentication
            }
        } catch (e: Exception) {
            logger.warn("JWT authentication failed: ${e.message}")
            SecurityContextHolder.clearContext()
        }

        filterChain.doFilter(request, response)
    }

    private fun extractTokenFromRequest(request: HttpServletRequest): String? {
        val bearerToken = request.getHeader("Authorization")
        return if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            bearerToken.substring(7)
        } else {
            null
        }
    }
}
