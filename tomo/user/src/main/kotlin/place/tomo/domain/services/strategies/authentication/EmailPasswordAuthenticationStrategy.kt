package place.tomo.domain.services.strategies.authentication

import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.stereotype.Component
import place.tomo.application.commands.AuthenticationCommand
import place.tomo.application.commands.EmailPasswordAuthCommand
import place.tomo.domain.services.JwtTokenProvider

@Component
class EmailPasswordAuthenticationStrategy(
    private val authenticationManager: AuthenticationManager,
    private val jwtTokenProvider: JwtTokenProvider,
) : AuthenticationStrategy {
    override fun supports(command: AuthenticationCommand): Boolean = command is EmailPasswordAuthCommand

    override fun authenticate(command: AuthenticationCommand): String {
        require(command is EmailPasswordAuthCommand) { "지원하지 않는 인증 방식입니다." }

        val authentication =
            authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken(command.email, command.password),
            )

        return jwtTokenProvider.issueToken(authentication.name)
    }
}
