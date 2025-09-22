package place.tomo.auth.application.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.application.requests.RefreshTokenRequest
import place.tomo.auth.application.responses.IssueTokenResponse
import place.tomo.auth.domain.commands.LinkSocialAccountCommand
import place.tomo.auth.domain.services.AuthenticationService
import place.tomo.auth.domain.services.SocialAccountDomainService
import place.tomo.auth.domain.services.jwt.JwtProvider
import place.tomo.auth.domain.services.jwt.JwtValidator
import place.tomo.common.exception.NotFoundActiveUserException
import place.tomo.contract.ports.UserDomainPort

@Service
class AuthenticationApplicationService(
    private val authenticateService: AuthenticationService,
    private val jwtProvider: JwtProvider,
    private val jwtValidator: JwtValidator,
    private val userDomainPort: UserDomainPort,
    private val socialAccountService: SocialAccountDomainService,
) {
    @Transactional
    fun signUp(request: OIDCSignUpRequest): IssueTokenResponse {
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

        return issueToken(userInfo.entityId.toString())
    }

    fun refreshToken(request: RefreshTokenRequest): IssueTokenResponse {
        val subject = jwtValidator.validateRefreshToken(request.refreshToken)
        userDomainPort.findActiveByEntityId(subject) ?: throw NotFoundActiveUserException(subject)

        return issueToken(subject)
    }

    private fun issueToken(subject: String): IssueTokenResponse {
        val accessToken = jwtProvider.issueAccessToken(subject)
        val refreshToken = jwtProvider.issueRefreshToken(subject)

        return IssueTokenResponse.fromJwtTokens(
            accessToken,
            refreshToken,
        )
    }
}
