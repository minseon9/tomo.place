package place.tomo.place.domain.command

import place.tomo.place.domain.entities.PlaceFolderEntity

data class CreatePlaceFolderSettingCommand(
    val userId: Long,
    val placeFolderEntity: PlaceFolderEntity,
    val name: String,
    val iconColor: String,
    val isDisplayStoredPlace: Boolean,
    val isDisplayVisitedPlace: Boolean,
)
