package place.tomo.auth.ui.responses

data class LoginResponseBody(
    val token: String,
    val refreshToken: String,
)
