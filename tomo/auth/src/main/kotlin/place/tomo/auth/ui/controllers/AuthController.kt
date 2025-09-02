package place.tomo.auth.ui.controllers

import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.requests.RefreshTokenRequest
import place.tomo.auth.application.services.AuthenticationApplicationService
import place.tomo.auth.ui.requests.RefreshTokenRequestBody
import place.tomo.auth.ui.requests.SignupRequestBody
import place.tomo.auth.ui.responses.LoginResponseBody
import place.tomo.auth.ui.responses.RefreshTokenResponseBody

@RestController
@RequestMapping("/api/auth")
class AuthController(
    private val authService: AuthenticationApplicationService,
) {
    @PostMapping("/signup")
    fun signUp(
        @RequestBody @Valid body: SignupRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val response = authService.signUp(OIDCSignUpRequest(body.provider, body.authorizationCode))

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
        @AuthenticationPrincipal user: UserDetails,
        @RequestBody @Valid body: RefreshTokenRequestBody,
    ): ResponseEntity<RefreshTokenResponseBody> {
        val response = authService.refreshToken(RefreshTokenRequest(user.username, body.refreshToken))

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
