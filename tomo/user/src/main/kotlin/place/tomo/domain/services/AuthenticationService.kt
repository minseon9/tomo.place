package place.tomo.domain.services

import org.springframework.stereotype.Service
import place.tomo.domain.commands.AuthenticationCommand
import place.tomo.domain.services.factories.authentication.AuthenticationStrategyFactory

@Service
class AuthenticationService(
    private val strategyFactory: AuthenticationStrategyFactory,
    private val jwtTokenProvider: JwtTokenProvider,
) {
    fun authenticate(command: AuthenticationCommand): String {
        val strategy = strategyFactory.getStrategy(command.getAuthType())
        val credentials = command.toCredentials()

        val subject = strategy.authenticate(credentials)

        return jwtTokenProvider.issueToken(subject)
    }
}
