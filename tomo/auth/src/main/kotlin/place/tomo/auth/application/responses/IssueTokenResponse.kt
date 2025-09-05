package place.tomo.auth.application.responses

import place.tomo.auth.domain.dtos.JwtToken

data class IssueTokenResponse(
    val accessToken: String,
    val refreshToken: String,
    val accessTokenExpiresAt: Long,
    val refreshTokenExpiresAt: Long,
) {
    companion object {
        fun fromJwtTokens(
            accessToken: JwtToken,
            refreshToken: JwtToken,
        ): IssueTokenResponse =
            IssueTokenResponse(
                accessToken = accessToken.token,
                refreshToken = refreshToken.token,
                accessTokenExpiresAt = accessToken.expiresAt.toEpochMilli(),
                refreshTokenExpiresAt = refreshToken.expiresAt.toEpochMilli(),
            )
    }
}
