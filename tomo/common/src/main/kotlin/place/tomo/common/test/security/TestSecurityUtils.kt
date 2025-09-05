package place.tomo.common.test.security

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors
import org.springframework.test.web.servlet.request.RequestPostProcessor

object TestSecurityUtils {
    private const val DEFAULT_EMAIL = "test@example.com"

    fun withUser(
        email: String = DEFAULT_EMAIL,
        roles: List<String> = listOf("USER"),
    ): RequestPostProcessor {
        val userDetails = createTestUser(email, roles)

        val authentication =
            UsernamePasswordAuthenticationToken(
                userDetails,
                null,
                userDetails.authorities,
            )
        return SecurityMockMvcRequestPostProcessors.authentication(authentication)
    }

    private fun createTestUser(
        email: String = DEFAULT_EMAIL,
        roles: List<String> = listOf("USER"),
    ): UserDetails =
        User
            .builder()
            .username(email)
            .password("password")
            .roles(*roles.toTypedArray())
            .build()
}
