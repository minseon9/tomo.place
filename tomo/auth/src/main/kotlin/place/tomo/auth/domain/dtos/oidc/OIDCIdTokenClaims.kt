package place.tomo.auth.domain.dtos.oidc

data class OIDCIdTokenClaims(
    val issuer: String,
    val subject: String,
    val audiences: List<String>,
    val expirationEpochSeconds: Long,
    val issuedAtEpochSeconds: Long,
    val email: String?,
    val emailVerified: Boolean?,
    val name: String?,
    val picture: String?,
)
