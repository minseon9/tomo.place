package place.tomo.auth.domain.dtos.oidc

data class OIDCEndpoints(
    val issuer: String,
    val authorizationEndpoint: String?,
    val tokenEndpoint: String,
    val userinfoEndpoint: String?,
    val jwksUri: String,
)
