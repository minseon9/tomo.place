package place.tomo.auth.domain.models

data class OidcToken(
    val accessToken: String,
    val refreshToken: String?,
    val expiresIn: Long?,
    val idToken: String? = null,
)
