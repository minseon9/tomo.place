package place.tomo.place.applicatoin.services.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.place.applicatoin.services.requests.CreatePlaceFolderRequest
import place.tomo.place.domain.command.CreatePlaceFolderCommand
import place.tomo.place.domain.constants.PlaceFolderVisibilityType
import place.tomo.place.domain.services.PlaceFolderDomainService

@Service
class PlaceFolderApplicationService(
    private val placeFolderService: PlaceFolderDomainService,
) {
    @Transactional
    fun createPlaceFolder(request: CreatePlaceFolderRequest) {
        placeFolderService.createPlaceFolder(
            CreatePlaceFolderCommand(
                name = request.name,
                ownerId = request.requestUser.id,
                visibility = PlaceFolderVisibilityType.valueOf(request.visibility),
                tags = null,
                settingUserId = request.requestUser.id,
                settingName = request.name,
                iconColor = request.iconColor,
                isDisplayStoredPlace = request.isDisplayStoredPlace,
                isDisplayVisitedPlace = request.isDisplayVisitedPlace,
            ),
        )
    }
}
