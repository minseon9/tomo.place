package place.tomo.place.ui.requests

import jakarta.validation.constraints.Max
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Pattern

data class CreatePlaceFolderRequestBody(
    @field:Pattern(regexp = "^(PRIVATE|PUBLIC)$")
    val visibility: String,
    @field:NotBlank()
    @field:Max(value = 20)
    val name: String,
    @field:Pattern(regexp = "^#[0-9a-fA-F]{6}$")
    val iconColor: String,
    val isDisplayStoredPlace: Boolean,
    val isDisplayVisitedPlace: Boolean,
)
