package place.tomo.auth.ui.controllers

import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.requests.RefreshTokenRequest
import place.tomo.auth.application.services.OIDCApplicationService
import place.tomo.auth.application.services.RefreshTokenApplicationService
import place.tomo.auth.ui.requests.SignupRequestBody
import place.tomo.auth.ui.responses.LoginResponseBody
import place.tomo.auth.ui.responses.RefreshTokenResponseBody

@RestController
@RequestMapping("/api/auth")
class AuthController(
    private val oidcAuthService: OIDCApplicationService,
    private val refreshTokenService: RefreshTokenApplicationService,
) {
    @PostMapping("/signup")
    fun signUp(
        @RequestBody @Valid body: SignupRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val response = oidcAuthService.signUp(OIDCSignUpRequest(body.provider, body.authorizationCode))

        return ResponseEntity.ok(
            LoginResponseBody(
                accessToken = response.accessToken,
                accessTokenExpiresAt = response.accessTokenExpiresAt,
                refreshToken = response.refreshToken,
                refreshTokenExpiresAt = response.refreshTokenExpiresAt,
            ),
        )
    }

    @PostMapping("/refresh")
    fun refreshToken(
        @RequestBody @Valid body: RefreshTokenRequest,
    ): ResponseEntity<RefreshTokenResponseBody> {
        val response = refreshTokenService.refreshToken(body)

        return ResponseEntity.ok(
            RefreshTokenResponseBody(
                accessToken = response.accessToken,
                accessTokenExpiresAt = response.accessTokenExpiresAt,
                refreshToken = response.refreshToken,
                refreshTokenExpiresAt = response.refreshTokenExpiresAt,
            ),
        )
    }
}
