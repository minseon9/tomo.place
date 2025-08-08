package place.tomo.auth.ui.requests

data class LoginRequestBody(
    val email: String,
    val password: String,
)
