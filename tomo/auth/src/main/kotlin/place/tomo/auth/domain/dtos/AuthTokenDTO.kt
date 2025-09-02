package place.tomo.auth.domain.dtos

data class AuthTokenDTO(
    val accessToken: String,
    val refreshToken: String,
    val accessTokenExpiresAt: Long,
    val refreshTokenExpiresAt: Long,
)
