package place.tomo.application.commands

data class SignUpCommand(
    val email: String,
    val password: String,
    val name: String,
)
