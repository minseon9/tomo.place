package place.tomo.place.ui.requests

import jakarta.validation.constraints.Max
import jakarta.validation.constraints.NotBlank

data class CreatePlaceFolderRequestBody(
    // folder 자체에 설정
    @field:NotBlank(message = "Refresh token is required")
    val visibility: String,
    // 사용자 별로 설정
    @field:NotBlank(message = "Refresh token is required")
    @field:Max(value = 20, message = "Refresh token is required")
    val name: String,
    val iconColor: String,
    val isDisplayStoredPlace: Boolean,
    val isDisplayVisitedPlace: Boolean,
)
