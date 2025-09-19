package place.tomo.place.domain.command

import place.tomo.place.domain.constants.PlaceFolderVisibilityType

data class CreatePlaceFolderCommand(
    val name: String,
    val ownerId: Long,
    val visibility: PlaceFolderVisibilityType,
    val tags: Array<String>?,
    val settingUserId: Long,
    val settingName: String,
    val iconColor: String,
    val isDisplayStoredPlace: Boolean,
    val isDisplayVisitedPlace: Boolean,
)
