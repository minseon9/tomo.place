package place.tomo.auth.ui.controllers

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.auth.application.requests.EmailPasswordAuthenticateRequest
import place.tomo.auth.application.requests.SignUpRequest
import place.tomo.auth.application.services.AuthApplicationService
import place.tomo.auth.ui.requests.LoginRequestBody
import place.tomo.auth.ui.requests.SignUpRequestBody
import place.tomo.auth.ui.responses.LoginResponseBody

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
            SignUpRequest(
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
        val response =
            authService.authenticate(
                EmailPasswordAuthenticateRequest(
                    email = body.email,
                    password = body.password,
                ),
            )

        return ResponseEntity.ok(LoginResponseBody(token = response.token, refreshToken = response.refreshToken))
    }
}
