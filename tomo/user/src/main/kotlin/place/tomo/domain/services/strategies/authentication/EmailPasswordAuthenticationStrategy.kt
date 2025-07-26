package place.tomo.domain.services.strategies.authentication

import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.stereotype.Component

class EmailPasswordAuthenticationStrategy internal constructor(
    private val authenticationManager: AuthenticationManager,
    private val email: String,
    private val password: String,
) : AuthenticationStrategy {
    override fun authenticate(): String {
        val authentication = authenticationManager.authenticate(UsernamePasswordAuthenticationToken(this.email, this.password))

        return authentication.name
    }
}

@Component
class EmailPasswordStrategy(
    private val userRepository: UserRepository,
) : AuthenticationStrategy<EmailPasswordCredentials>() {
    override fun authenticate(credentials: EmailPasswordCredentials): AuthResult {
        return try {
            val user =
                userRepository.findByEmail(credentials.email)
                    ?: return AuthResult.Failure("User not found")

            if (BCrypt.checkpw(credentials.password, user.password)) {
                createAuthResult(user)
            } else {
                AuthResult.Failure("Invalid password")
            }
        } catch (e: Exception) {
            AuthResult.Failure("Authentication failed: ${e.message}")
        }
    }

    override fun supports(type: AuthType): Boolean = type == AuthType.EMAIL
}
