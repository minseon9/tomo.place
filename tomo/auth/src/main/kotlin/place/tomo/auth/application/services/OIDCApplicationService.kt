package place.tomo.auth.application.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.auth.application.requests.OIDCAuthenticateRequest
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.responses.LoginResponse
import place.tomo.auth.domain.commands.LinkSocialAccountCommand
import place.tomo.auth.domain.services.AuthenticationService
import place.tomo.auth.domain.services.SocialAccountDomainService
import place.tomo.auth.domain.services.TemporaryPasswordGenerator
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserDomainPort

@Service
class OIDCApplicationService(
    private val authenticateService: AuthenticationService,
    private val userDomainPort: UserDomainPort,
    private val socialAccountService: SocialAccountDomainService,
    private val temporaryPasswordGenerator: TemporaryPasswordGenerator,
) {
    @Transactional
    fun signUp(request: OIDCSignUpRequest): LoginResponse {
        val oidcUserInfo = authenticateService.getOidcUserInfo(request.provider, request.authorizationCode)

        val userInfo = getOrCreateUser(oidcUserInfo.email, oidcUserInfo.name)

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

        return LoginResponse(token = authToken.accessToken, refreshToken = authToken.refreshToken)
    }

    fun authenticate(request: OIDCAuthenticateRequest): LoginResponse {
        val authToken = authenticateService.authenticateOIDC(request.provider, request.authorizationCode)

        return LoginResponse(token = authToken.accessToken, refreshToken = authToken.refreshToken)
    }

    private fun getOrCreateUser(
        email: String,
        name: String,
    ): UserInfoDTO {
        val existingUser = userDomainPort.findByEmail(email)
        if (existingUser != null) {
            return existingUser
        }

        val tempPassword = temporaryPasswordGenerator.generate()
        return userDomainPort.create(
            email = email,
            rawPassword = tempPassword,
            name = name,
        )
    }
}
