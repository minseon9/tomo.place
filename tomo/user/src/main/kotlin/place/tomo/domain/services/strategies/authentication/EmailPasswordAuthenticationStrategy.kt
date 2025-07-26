package place.tomo.domain.services.strategies.authentication

import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.stereotype.Component
import place.tomo.contract.constant.AuthenticationType
import place.tomo.domain.commands.AuthCredentials
import place.tomo.domain.commands.EmailPasswordCredentials

@Component
class EmailPasswordAuthenticationStrategy(
    private val authenticationManager: AuthenticationManager,
) : AuthenticationStrategy() {
    override fun supports(type: AuthenticationType): Boolean = type == AuthenticationType.EMAILPASSWORD

    override fun authenticate(credentials: AuthCredentials): String {
        val emailCreds = credentials as EmailPasswordCredentials

        val authentication =
            authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken(emailCreds.email, emailCreds.password),
            )

        return authentication.name
    }
}
