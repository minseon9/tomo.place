package place.tomo.application.requests

import place.tomo.domain.constant.OAuthProvider

data class EmailPasswordAuthenticateRequest(
    val email: String,
    val password: String,
)

data class OAuthAuthenticateRequest(
    val provider: OAuthProvider,
    val authorizationCode: String,
)
