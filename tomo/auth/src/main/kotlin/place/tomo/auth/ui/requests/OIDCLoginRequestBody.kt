package place.tomo.auth.ui.requests

import place.tomo.contract.constant.OIDCProviderType

data class OIDCLoginRequestBody(
    val provider: OIDCProviderType,
    val authorizationCode: String,
)
