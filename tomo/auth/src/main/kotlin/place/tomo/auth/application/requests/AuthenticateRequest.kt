package place.tomo.auth.application.requests

import place.tomo.contract.constant.OIDCProviderType

data class EmailPasswordAuthenticateRequest(
    val email: String,
    val password: String,
)

data class OIDCAuthenticateRequest(
    val provider: OIDCProviderType,
    val authorizationCode: String,
)
