package place.tomo.auth.application.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.responses.LoginResponse
import place.tomo.auth.domain.commands.LinkSocialAccountCommand
import place.tomo.auth.domain.services.AuthenticationService
import place.tomo.auth.domain.services.SocialAccountDomainService
import place.tomo.contract.ports.UserDomainPort

@Service
class OIDCApplicationService(
    private val authenticateService: AuthenticationService,
    private val userDomainPort: UserDomainPort,
    private val socialAccountService: SocialAccountDomainService,
) {
    @Transactional
    fun signUp(request: OIDCSignUpRequest): LoginResponse {
        val oidcUserInfo = authenticateService.getOidcUserInfo(request.provider, request.authorizationCode)

        val userInfo = userDomainPort.getOrCreateActiveUser(oidcUserInfo.email, oidcUserInfo.name)

        socialAccountService.linkSocialAccount(
            LinkSocialAccountCommand(
                user = userInfo,
                provider = request.provider,
                socialId = oidcUserInfo.socialId,
                email = oidcUserInfo.email,
                name = oidcUserInfo.name,
                profileImageUrl = oidcUserInfo.profileImageUrl,
            ),
        )

        val authToken = authenticateService.issueOIDCUserAuthToken(oidcUserInfo)

        return LoginResponse(
            accessToken = authToken.accessToken,
            refreshToken = authToken.refreshToken,
            accessTokenExpiresAt = authToken.accessTokenExpiresAt,
            refreshTokenExpiresAt = authToken.refreshTokenExpiresAt,
        )
    }
}
