package place.tomo.place.ui.controllers

import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.contract.dtos.AuthorizedUserDTO
import place.tomo.place.applicatoin.services.requests.CreatePlaceFolderRequest
import place.tomo.place.applicatoin.services.services.PlaceFolderApplicationService
import place.tomo.place.ui.requests.CreatePlaceFolderRequestBody

@RestController
@RequestMapping("/api/place-folder")
class PlaceFolderController(
    private val applicationService: PlaceFolderApplicationService,
) {
    @PostMapping()
    fun create(
        @AuthenticationPrincipal user: AuthorizedUserDTO,
        @RequestBody @Valid body: CreatePlaceFolderRequestBody,
    ): ResponseEntity<Void> {
        applicationService.createPlaceFolder(
            CreatePlaceFolderRequest(
                user,
                body.visibility,
                body.name,
                body.iconColor,
                body.isDisplayStoredPlace,
                body.isDisplayVisitedPlace,
            ),
        )

        return ResponseEntity.ok().build()
    }
}
