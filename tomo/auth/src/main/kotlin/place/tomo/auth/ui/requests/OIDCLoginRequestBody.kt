package place.tomo.auth.ui.requests

import jakarta.validation.constraints.NotBlank
import place.tomo.contract.constant.OIDCProviderType

data class OIDCLoginRequestBody(
    @NotBlank
    val provider: OIDCProviderType,
    @NotBlank
    val authorizationCode: String,
)
