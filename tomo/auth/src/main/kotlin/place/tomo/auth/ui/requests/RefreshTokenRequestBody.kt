package place.tomo.auth.ui.requests

import jakarta.validation.constraints.NotBlank

data class RefreshTokenRequestBody(
    @field:NotBlank(message = "Refresh token is required")
    val refreshToken: String,
)
