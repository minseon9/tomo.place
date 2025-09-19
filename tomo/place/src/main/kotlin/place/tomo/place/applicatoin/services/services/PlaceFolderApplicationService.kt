package place.tomo.place.applicatoin.services.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.place.applicatoin.services.requests.CreatePlaceFolderRequest
import place.tomo.place.domain.command.CreatePlaceFolderCommand
import place.tomo.place.domain.command.CreatePlaceFolderSettingCommand
import place.tomo.place.domain.constants.PlaceFolderVisibilityType
import place.tomo.place.domain.services.PlaceFolderDomainService
import place.tomo.place.domain.services.PlaceFolderSettingDomainService

@Service
class PlaceFolderApplicationService(
    private val placeFolderService: PlaceFolderDomainService,
    private val placeFolderSettingService: PlaceFolderSettingDomainService,
) {
    @Transactional
    fun createPlaceFolder(request: CreatePlaceFolderRequest) {
        val placeFolder =
            placeFolderService.createPlaceFolder(
                CreatePlaceFolderCommand(
                    request.requestUser.id,
                    PlaceFolderVisibilityType.valueOf(request.visibility),
                    request.name,
                ),
            )

        placeFolderSettingService.createUserSetting(
            CreatePlaceFolderSettingCommand(
                request.requestUser.id,
                placeFolder,
                request.name,
                request.iconColor,
                request.isDisplayStoredPlace,
                request.isDisplayVisitedPlace,
            ),
        )
    }
}
