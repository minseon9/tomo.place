package place.tomo.auth.domain.dtos

import java.time.Instant

data class JwtToken(
    val token: String,
    val expiresAt: Instant,
)
