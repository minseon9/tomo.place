package place.tomo.ui.controllers

import place.tomo.application.commands.LoginCommand
import place.tomo.application.services.AuthApplicationService
import place.tomo.application.commands.SignUpCommand
import place.tomo.ui.requests.SignUpRequestBody
import place.tomo.ui.requests.LoginRequestBody
import place.tomo.ui.responses.LoginResponseBody
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/auth")
class AuthController(
    private val authService: AuthApplicationService,
) {
    @PostMapping("/signup")
    fun signUp(
        @RequestBody request: SignUpRequestBody,
    ): ResponseEntity<Void> {
        authService.signUp(
            SignUpCommand(
                email = request.email,
                password = request.password,
                name = request.name,
            ),
        )

        return ResponseEntity.ok().build()
    }

    @PostMapping("/login")
    fun login(
        @RequestBody request: LoginRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val response =
            authService.login(
                LoginCommand(
                    email = request.email,
                    password = request.password,
                ),
            )

        return ResponseEntity.ok(LoginResponseBody(token = response))
    }
}
