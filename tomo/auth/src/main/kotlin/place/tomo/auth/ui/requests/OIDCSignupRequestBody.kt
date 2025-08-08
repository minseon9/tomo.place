package place.tomo.auth.ui.requests

import place.tomo.contract.constant.OIDCProviderType

data class OIDCSignupRequestBody(
    val provider: OIDCProviderType,
    val authorizationCode: String,
    val state: String,
)
