package place.tomo.place.domain.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.place.domain.command.CreatePlaceFolderSettingCommand
import place.tomo.place.domain.entities.PlaceFolderSettingEntity
import place.tomo.place.infra.repositories.PlaceFolderSettingRepository

@Service
class PlaceFolderSettingDomainService(
    private val repository: PlaceFolderSettingRepository,
) {
    @Transactional
    fun createUserSetting(command: CreatePlaceFolderSettingCommand): PlaceFolderSettingEntity {
        val setting =
            PlaceFolderSettingEntity.create(
                command.userId,
                command.placeFolderEntity,
                command.name,
                command.iconColor,
                command.isDisplayStoredPlace,
                command.isDisplayVisitedPlace,
            )

        repository.save(setting)

        return setting
    }
}
