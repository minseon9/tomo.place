package place.tomo.auth.domain.services.oidc

interface OIDCProperties {
    val clientId: String
    val clientSecret: String
    val redirectUri: String
}
