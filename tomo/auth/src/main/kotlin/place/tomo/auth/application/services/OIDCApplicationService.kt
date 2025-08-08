package place.tomo.auth.application.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.auth.application.requests.OIDCAuthenticateRequest
import place.tomo.auth.application.requests.OIDCSignUpRequest
import place.tomo.auth.domain.commands.LinkSocialAccountCommand
import place.tomo.auth.domain.services.AuthenticationService
import place.tomo.domain.services.SocialAccountDomainService

@Service
class OIDCApplicationService(
    private val authenticateService: AuthenticationService,
    private val socialAccountService: SocialAccountDomainService,
) {
    @Transactional
    fun signUp(request: OIDCSignUpRequest) {
        // FIXME: token에서부터 user 정보 가져온 후에 생성해줘야함
        val userInfo = authenticateService.getOidcUserInfo(request.provider, request.authorizationCode)

        socialAccountQueryPort.linkSocialAccount(
            LinkSocialAccountCommand(
                provider = request.provider,
                socialId = userInfo.socialId,
                email = userInfo.email,
                name = userInfo.name,
                profileImageUrl = userInfo.profileImageUrl,
            ),
        )
    }

    fun authenticate(request: OIDCAuthenticateRequest): String {
//        val authToken = authenticateService.authenticateOAuth(request.provider, request.authorizationCode)
//
//        // TODO: refresh token 발급 혹은 사용해서 access token refresh
//        // TODO: 위 상황 로그 남기기 ?
//        return authToken.accessToken
        return ""
    }
}
