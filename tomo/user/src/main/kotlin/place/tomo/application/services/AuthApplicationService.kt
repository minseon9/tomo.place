package place.tomo.application.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.application.commands.SignUpCommand
import place.tomo.application.requests.EmailPasswordAuthenticateRequest
import place.tomo.domain.commands.EmailLoginCommand
import place.tomo.domain.services.AuthenticationService
import place.tomo.domain.services.UserDomainService

// 계정 생성 (계정 연결)
// 권한 인증
// 계정 삭제 (연결 삭제)
@Service
class AuthApplicationService(
    private val authenticateService: AuthenticationService,
    private val userDomainService: UserDomainService,
) {
    @Transactional
    fun signUp(command: SignUpCommand) {
        userDomainService.createUser(command.email, command.password, command.name)

        // TODO: email 인증 번호 저장
        // TODO: email 인증 발송
    }

    fun authenticate(request: EmailPasswordAuthenticateRequest): String =
        authenticateService.authenticate(command = EmailLoginCommand(request.email, request.password))

//    fun deleteAuthentication() {
//        val authenticatedSubject = authenticateServiceFactory.getService(type).deleteAuthentication()
//    }
}
