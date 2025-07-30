package place.tomo.application.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.application.commands.SignUpCommand
import place.tomo.application.requests.EmailPasswordAuthenticateRequest
import place.tomo.domain.services.AuthenticationService
import place.tomo.domain.services.JwtTokenProvider
import place.tomo.domain.services.UserDomainService

@Service
class AuthApplicationService(
    private val authenticateService: AuthenticationService,
    private val userDomainService: UserDomainService,
    private val jwtTokenProvider: JwtTokenProvider,
) {
    @Transactional
    fun signUp(command: SignUpCommand) {
        userDomainService.createUser(command.email, command.password, command.name)

        // TODO: email 인증 번호 저장
        // TODO: email 인증 발송
    }

    fun authenticate(request: EmailPasswordAuthenticateRequest): String {
        val userInfo = authenticateService.authenticateEmailPassword(request.email, request.password)

        return jwtTokenProvider.issueToken(userInfo.email)
    }

//    fun deleteAuthentication() {
//        val authenticatedSubject = authenticateServiceFactory.getService(type).deleteAuthentication()
//    }
}
