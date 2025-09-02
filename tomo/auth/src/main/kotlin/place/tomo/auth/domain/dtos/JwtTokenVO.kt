package place.tomo.auth.domain.dtos

data class JwtTokenVO(
    val token: String,
    val expiresAt: Long,
)
