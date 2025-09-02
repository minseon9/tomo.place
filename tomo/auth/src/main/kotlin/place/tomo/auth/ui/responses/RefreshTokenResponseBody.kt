package place.tomo.auth.ui.responses

data class RefreshTokenResponseBody(
    val accessToken: String,
    val refreshToken: String,
    val accessTokenExpiresAt: Long,
    val refreshTokenExpiresAt: Long,
)
