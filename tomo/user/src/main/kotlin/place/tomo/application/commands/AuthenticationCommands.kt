package place.tomo.application.commands

import place.tomo.domain.constant.OAuthProvider

sealed class AuthenticationCommand

data class EmailPasswordAuthCommand(
    val email: String,
    val password: String
) : AuthenticationCommand()

data class OAuthAuthCommand(
    val provider: OAuthProvider,
    val authorizationCode: String
) : AuthenticationCommand()

data class SocialAccountLinkCommand(
    val userId: Long,
    val provider: OAuthProvider,
    val authorizationCode: String
) : AuthenticationCommand()

// 기존 Commands
data class SignUpCommand(
    val email: String,
    val password: String,
    val name: String,
)

data class LoginCommand(
    val email: String,
    val password: String,
) 