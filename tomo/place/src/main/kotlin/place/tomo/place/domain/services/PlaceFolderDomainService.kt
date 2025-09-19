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
        val folder = PlaceFolderEntity.create(command.name, command.userId, command.visibility)

        repository.save(folder)

        return folder
    }
}
