package place.tomo.domain.services.strategies.authentication

import place.tomo.contract.constant.AuthenticationType
import place.tomo.domain.commands.AuthCredentials

abstract class AuthenticationStrategy {
    abstract fun authenticate(credentials: AuthCredentials): String

    abstract fun supports(type: AuthenticationType): Boolean
}
