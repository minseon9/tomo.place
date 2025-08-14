package place.tomo.auth.ui.requests

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

data class LoginRequestBody(
    @Email
    @NotBlank
    val email: String,
    @NotBlank
    @Size(min = 8, max = 20)
    val password: String,
)
