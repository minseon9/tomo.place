package place.tomo.auth.domain.dtos

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties("security.jwt")
data class JwtPropertiesDTO(
    val issuer: String,
    val audiences: List<String>,
    val accessTtlSeconds: Long,
    val refreshTtlSeconds: Long,
)
