package place.tomo.auth.ui.requests

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

data class SignUpRequestBody(
    @field:Email
    @field:Size(max = 254)
    @field:NotBlank
    val email: String,
    @field:NotBlank
    @field:Size(min = 8, max = 20)
    val password: String,
    @field:NotBlank
    val name: String,
)
