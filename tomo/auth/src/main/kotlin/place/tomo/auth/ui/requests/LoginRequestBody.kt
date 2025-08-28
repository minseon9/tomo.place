package place.tomo.auth.ui.requests

import jakarta.validation.constraints.NotBlank
import place.tomo.contract.constant.OIDCProviderType

data class LoginRequestBody(
    val provider: OIDCProviderType,
    @field:NotBlank
    val authorizationCode: String,
)
