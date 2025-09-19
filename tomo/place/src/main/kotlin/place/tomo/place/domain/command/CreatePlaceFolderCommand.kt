package place.tomo.place.domain.command

import jakarta.validation.constraints.Max
import jakarta.validation.constraints.NotBlank
import place.tomo.place.domain.constants.PlaceFolderVisibilityType

data class CreatePlaceFolderCommand(
    val userId: Long,
    val visibility: PlaceFolderVisibilityType,
    val name: String,
)
