package place.tomo.auth.domain.dtos

data class JwtToken(
    val token: String,
    val expiresAt: Long,
)
