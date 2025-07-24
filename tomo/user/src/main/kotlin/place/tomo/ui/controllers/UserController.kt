package place.tomo.ui.controllers

import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.application.services.UserApplicationService

@RestController
@RequestMapping("/api/users")
class UserController(
    private val userService: UserApplicationService,
)
