package place.tomo.auth.domain.dtos

data class AuthTokenDTO(
    val accessToken: String,
    val refreshToken: String,
    val accessTokenExpiresAt: Long,
    val refreshTokenExpiresAt: Long,
) {
    companion object {
        fun fromJwtTokens(
            accessToken: JwtToken,
            refreshToken: JwtToken,
        ): AuthTokenDTO =
            AuthTokenDTO(
                accessToken = accessToken.token,
                refreshToken = refreshToken.token,
                accessTokenExpiresAt = accessToken.expiresAt.toEpochMilli(),
                refreshTokenExpiresAt = refreshToken.expiresAt.toEpochMilli(),
            )
    }
}
