package place.tomo.ui.controllers

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.application.commands.SignUpCommand
import place.tomo.application.requests.EmailPasswordAuthenticateRequest
import place.tomo.application.services.AuthApplicationService
import place.tomo.ui.requests.LoginRequestBody
import place.tomo.ui.requests.SignUpRequestBody
import place.tomo.ui.responses.LoginResponseBody

@RestController
@RequestMapping("/api/auth")
class AuthController(
    private val authService: AuthApplicationService,
) {
    @PostMapping("/signup")
    fun signUp(
        @RequestBody body: SignUpRequestBody,
    ): ResponseEntity<Void> {
        authService.signUp(
            SignUpCommand(
                email = body.email,
                password = body.password,
                name = body.name,
            ),
        )
        return ResponseEntity.ok().build()
    }

    @PostMapping("/login")
    fun login(
        @RequestBody body: LoginRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val token =
            authService.authenticate(
                EmailPasswordAuthenticateRequest(
                    email = body.email,
                    password = body.password,
                ),
            )
        return ResponseEntity.ok(LoginResponseBody(token = token))
    }
}
