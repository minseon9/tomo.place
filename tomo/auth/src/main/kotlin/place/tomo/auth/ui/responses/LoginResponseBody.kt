package place.tomo.auth.ui.responses

data class LoginResponseBody(
    val accessToken: String,
    val refreshToken: String,
    val accessTokenExpiresAt: Long,
    val refreshTokenExpiresAt: Long,
)
