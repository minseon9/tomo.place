package place.tomo.auth.ui.controllers

import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.services.OIDCApplicationService
import place.tomo.auth.ui.requests.SignupRequestBody
import place.tomo.auth.ui.responses.LoginResponseBody

@RestController
@RequestMapping("/api/auth")
class AuthController(
    private val oidcAuthService: OIDCApplicationService,
) {
    @PostMapping("/signup")
    fun signUp(
        @RequestBody @Valid body: SignupRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val response = oidcAuthService.signUp(OIDCSignUpRequest(body.provider, body.authorizationCode))

        return ResponseEntity.ok(LoginResponseBody(token = response.token, refreshToken = response.refreshToken))
    }
}
