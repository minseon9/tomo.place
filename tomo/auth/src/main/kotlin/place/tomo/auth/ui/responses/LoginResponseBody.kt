package place.tomo.auth.ui.responses

data class LoginResponseBody(
    val accessToken: String,
    val accessTokenExpiresAt: Long,
    val refreshToken: String,
    val refreshTokenExpiresAt: Long,
)
