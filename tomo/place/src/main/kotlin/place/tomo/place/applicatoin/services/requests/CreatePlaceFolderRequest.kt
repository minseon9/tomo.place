package place.tomo.place.applicatoin.services.requests

import jakarta.validation.constraints.Max
import jakarta.validation.constraints.NotBlank
import place.tomo.contract.dtos.AuthorizedUserDTO

data class CreatePlaceFolderRequest(
    val requestUser: AuthorizedUserDTO,
    @field:NotBlank(message = "Refresh token is required")
    val visibility: String,
    @field:NotBlank(message = "Refresh token is required")
    @field:Max(value = 20, message = "Refresh token is required")
    val name: String,
    @field:NotBlank(message = "Refresh token is required")
    val iconColor: String,
    val isDisplayStoredPlace: Boolean,
    val isDisplayVisitedPlace: Boolean,
)
