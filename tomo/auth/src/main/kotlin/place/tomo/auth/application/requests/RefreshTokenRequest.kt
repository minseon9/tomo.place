package place.tomo.auth.application.requests

import jakarta.validation.constraints.NotBlank

data class RefreshTokenRequest(
    @field:NotBlank
    val userEmail: String,
    @field:NotBlank
    val refreshToken: String,
)
