package place.tomo.auth.ui.controllers

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.services.OIDCApplicationService
import place.tomo.auth.ui.requests.OIDCSignupRequestBody

@RestController
@RequestMapping("/api/oidc")
class OIDCController(
    private val authService: OIDCApplicationService,
) {
    // OIDC authentication & JWT 발급
    @PostMapping("/signup")
    fun signUp(
        @RequestBody request: OIDCSignupRequestBody,
    ): ResponseEntity<Void> {
        authService.signUp(OIDCSignUpRequest(request.provider, request.authorizationCode, request.state))

        return ResponseEntity.ok().build()
    }

    // JWT 검증 & Refresh Token 재발급
//    @PostMapping("/login")
//    fun authenticate(
//        @RequestBody body: OIDCLoginRequestBody,
//    ): ResponseEntity<LoginResponseBody> {
//        val token = authService.authenticate(OIDCAuthenticateRequest(body.provider, body.authorizationCode, body.state))
//
//        return ResponseEntity.ok(LoginResponseBody(token = token))
//    }
}
