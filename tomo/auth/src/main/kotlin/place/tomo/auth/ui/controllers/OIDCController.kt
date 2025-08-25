package place.tomo.auth.ui.controllers

import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.auth.application.requests.OIDCAuthenticateRequest
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.services.OIDCApplicationService
import place.tomo.auth.ui.requests.OIDCLoginRequestBody
import place.tomo.auth.ui.requests.OIDCSignupRequestBody
import place.tomo.auth.ui.responses.LoginResponseBody

@RestController
@RequestMapping("/api/oidc")
class OIDCController(
    private val oidcAuthService: OIDCApplicationService,
) {
    @PostMapping("/signup")
    fun signUp(
        @RequestBody @Valid body: OIDCSignupRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val response = oidcAuthService.signUp(OIDCSignUpRequest(body.provider, body.authorizationCode))

        return ResponseEntity.ok(LoginResponseBody(token = response.token, refreshToken = response.refreshToken))
    }

    @PostMapping("/login")
    fun authenticate(
        @RequestBody @Valid body: OIDCLoginRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val response = oidcAuthService.authenticate(OIDCAuthenticateRequest(body.provider, body.authorizationCode))

        return ResponseEntity.ok(LoginResponseBody(token = response.token, refreshToken = response.refreshToken))
    }
}
