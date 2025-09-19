package place.tomo.place.domain.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.place.domain.command.CreatePlaceFolderCommand
import place.tomo.place.domain.entities.PlaceFolderEntity
import place.tomo.place.infra.repositories.PlaceFolderRepository

@Service
class PlaceFolderDomainService(
    private val repository: PlaceFolderRepository,
) {
    @Transactional
    fun createPlaceFolder(command: CreatePlaceFolderCommand): PlaceFolderEntity {
        val placeFolder =
            PlaceFolderEntity.create(
                name = command.name,
                userId = command.ownerId,
                visibility = command.visibility,
                tags = command.tags,
            )

        placeFolder.addUserSetting(
            userId = command.settingUserId,
            name = command.settingName,
            iconColor = command.iconColor,
            isDisplayStoredPlace = command.isDisplayStoredPlace,
            isDisplayVisitedPlace = command.isDisplayVisitedPlace,
        )

        return repository.save(placeFolder)
    }
}
