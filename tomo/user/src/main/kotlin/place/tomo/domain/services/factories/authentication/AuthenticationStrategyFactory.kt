package place.tomo.domain.services.factories.authentication

import org.springframework.stereotype.Component
import place.tomo.contract.constant.AuthenticationType
import place.tomo.domain.services.strategies.authentication.AuthenticationStrategy

@Component
class AuthenticationStrategyFactory(
    private val strategies: List<AuthenticationStrategy>,
) {
    fun getStrategy(type: AuthenticationType): AuthenticationStrategy =
        strategies.find { it.supports(type) }
            ?: throw IllegalArgumentException("No provider found for type: $type")
}
