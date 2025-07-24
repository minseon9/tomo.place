package place.tomo.application.commands

data class LoginCommand(
    val email: String,
    val password: String,
)
