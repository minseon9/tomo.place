package place.tomo.auth.domain.dtos.oidc

data class OIDCTokens(
    val accessToken: String,
    val refreshToken: String?,
    val idToken: String,
    val expiresIn: Long?,
)
