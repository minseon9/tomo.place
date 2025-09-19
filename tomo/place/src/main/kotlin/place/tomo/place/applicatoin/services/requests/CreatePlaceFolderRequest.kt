package place.tomo.place.applicatoin.services.requests

import jakarta.validation.constraints.Max
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Pattern
import place.tomo.contract.dtos.AuthorizedUserDTO

data class CreatePlaceFolderRequest(
    val requestUser: AuthorizedUserDTO,
    val visibility: String,
    val name: String,
    val iconColor: String,
    val isDisplayStoredPlace: Boolean,
    val isDisplayVisitedPlace: Boolean,
)
