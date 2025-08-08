package place.tomo.auth.application.responses

data class LoginResponse(
    val token: String,
    val refreshToken: String,
)
