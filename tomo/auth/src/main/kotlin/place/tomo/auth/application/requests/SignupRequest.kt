package place.tomo.auth.application.requests
import place.tomo.contract.constant.OIDCProviderType

data class OIDCSignUpRequest(
    val provider: OIDCProviderType,
    val authorizationCode: String,
    val state: String? = null,
)

data class SignUpRequest(
    val email: String,
    val password: String,
    val name: String,
)
