package place.tomo.auth.application.responses

data class LoginResponse(
    val accessToken: String,
    val refreshToken: String,
    val accessTokenExpiresAt: Long,
    val refreshTokenExpiresAt: Long,
)
