package place.tomo.ui.controllers

import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.application.services.AuthApplicationService
import place.tomo.ui.requests.SocialAccountDeleteRequestBody
import place.tomo.ui.requests.SocialLoginRequestBody
import place.tomo.ui.responses.LinkedSocialAccountsResponseBody
import place.tomo.ui.responses.LoginResponseBody
import place.tomo.ui.responses.SocialAccountResponseBody

@RestController
@RequestMapping("/api/oauth")
class OauthController(
    private val authService: AuthApplicationService,
) {
    @PostMapping("/social-login")
    fun socialLogin(
        @RequestBody request: SocialLoginRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val token = authService.socialLogin(request.provider, request.authorizationCode)

        return ResponseEntity.ok(LoginResponseBody(token = token))
    }

    // FIXME: UserContext 사용하도록 수정
    @PostMapping("/social-accounts")
    fun linkSocialAccount(
        @RequestBody request: SocialLoginRequestBody,
        @AuthenticationPrincipal user: UserDetails,
    ): ResponseEntity<Void> {
        val userId =
            authService.getUserByEmail(user.username)?.id
                ?: throw IllegalArgumentException("회원을 찾을 수 없습니다: ${user.username}")

        authService.linkSocialAccount(userId, request.provider, request.authorizationCode)
        return ResponseEntity.ok().build()
    }

    @DeleteMapping("/social-accounts")
    fun unlinkSocialAccount(
        @RequestBody request: SocialAccountDeleteRequestBody,
        @AuthenticationPrincipal user: UserDetails,
    ): ResponseEntity<Void> {
        val userId =
            authService.getUserByEmail(user.username)?.id
                ?: throw IllegalArgumentException("회원을 찾을 수 없습니다: ${user.username}")

        authService.unlinkSocialAccount(userId, request.provider)
        return ResponseEntity.ok().build()
    }

    // FIXME: Response Body가 build의 책임을 지도록 수정
    @GetMapping("/social-accounts")
    fun getLinkedSocialAccounts(
        @AuthenticationPrincipal user: UserDetails,
    ): ResponseEntity<LinkedSocialAccountsResponseBody> {
        val userId =
            authService.getUserByEmail(user.username)?.id
                ?: throw IllegalArgumentException("회원을 찾을 수 없습니다: ${user.username}")

        val socialAccounts = authService.getLinkedSocialAccounts(userId)

        val response =
            LinkedSocialAccountsResponseBody(
                accounts =
                    socialAccounts.map {
                        SocialAccountResponseBody(
                            provider = it.provider,
                            email = it.email,
                            name = it.name,
                            profileImageUrl = it.profileImageUrl,
                            isActive = it.isActive,
                        )
                    },
            )

        return ResponseEntity.ok(response)
    }
}
