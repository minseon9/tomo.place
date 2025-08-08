package place.tomo.auth.domain.dtos

data class AuthTokenDTO(
    val accessToken: String,
    val refreshToken: String,
    val expiresIn: Long? = null,
    val idToken: String? = null,
)
