package place.tomo.domain.services.strategies.authentication

import place.tomo.application.commands.AuthenticationCommand

interface AuthenticationStrategy {
    fun supports(command: AuthenticationCommand): Boolean

    fun authenticate(command: AuthenticationCommand): String // JWT 토큰 반환
}
