package dev.ian.mapa.auth.ui.controllers

import dev.ian.mapa.application.commands.LoginCommand
import dev.ian.mapa.application.services.AuthApplicationService
import dev.ian.mapa.auth.application.commands.SignUpCommand
import dev.ian.mapa.auth.ui.requests.SignUpRequestBody
import dev.ian.mapa.ui.requests.LoginRequestBody
import dev.ian.mapa.ui.responses.LoginResponseBody
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
