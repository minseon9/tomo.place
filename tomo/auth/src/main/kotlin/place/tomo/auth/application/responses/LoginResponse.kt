package place.tomo.auth.application.responses

import place.tomo.auth.domain.dtos.AuthTokenDTO

data class LoginResponse(
    val accessToken: String,
    val refreshToken: String,
    val accessTokenExpiresAt: Long,
    val refreshTokenExpiresAt: Long,
) {
    companion object {
        fun fromDto(dto: AuthTokenDTO): LoginResponse =
            LoginResponse(
                accessToken = dto.accessToken,
                refreshToken = dto.refreshToken,
                accessTokenExpiresAt = dto.accessTokenExpiresAt,
                refreshTokenExpiresAt = dto.refreshTokenExpiresAt,
            )
    }
}
