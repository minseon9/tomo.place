package place.tomo.ui.controllers

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.application.requests.OAuthAuthenticateRequest
import place.tomo.application.services.OauthApplicationService
import place.tomo.common.resolvers.usercontext.CurrentUser
import place.tomo.common.resolvers.usercontext.UserContext
import place.tomo.ui.requests.SocialAccountDeleteRequestBody
import place.tomo.ui.requests.SocialLoginRequestBody
import place.tomo.ui.responses.LoginResponseBody

@RestController
@RequestMapping("/api/oauth")
class OauthController(
    private val authService: OauthApplicationService,
) {
    @PostMapping("/social-accounts")
    fun linkSocialAccount(
        @RequestBody request: SocialLoginRequestBody,
    ): ResponseEntity<Void> {
        authService.linkSocialAccount(request.provider, request.authorizationCode)

        return ResponseEntity.ok().build()
    }

    @PostMapping("/social-login")
    fun socialLogin(
        @RequestBody body: SocialLoginRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val token =
            authService.authenticate(
                OAuthAuthenticateRequest(
                    provider = body.provider,
                    authorizationCode = body.authorizationCode,
                ),
            )

        return ResponseEntity.ok(LoginResponseBody(token = token))
    }

    @DeleteMapping("/social-accounts")
    fun unlinkSocialAccount(
        @RequestBody request: SocialAccountDeleteRequestBody,
        @CurrentUser userContext: UserContext,
    ): ResponseEntity<Void> {
        authService.unlinkSocialAccount(userContext.userId, request.provider)

        return ResponseEntity.ok().build()
    }
}
