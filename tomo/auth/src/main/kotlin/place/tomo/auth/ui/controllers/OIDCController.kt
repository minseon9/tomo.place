package place.tomo.auth.ui.controllers

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
    private val authService: OIDCApplicationService,
) {
    @PostMapping("/signup")
    fun signUp(
        @RequestBody request: OIDCSignupRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val response = authService.signUp(OIDCSignUpRequest(request.provider, request.authorizationCode))

        return ResponseEntity.ok(LoginResponseBody(token = response.token, refreshToken = response.refreshToken))
    }

    @PostMapping("/login")
    fun authenticate(
        @RequestBody body: OIDCLoginRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val response = authService.authenticate(OIDCAuthenticateRequest(body.provider, body.authorizationCode))

        return ResponseEntity.ok(LoginResponseBody(token = response.token, refreshToken = response.refreshToken))
    }
}
