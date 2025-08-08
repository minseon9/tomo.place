package place.tomo.auth.application.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.auth.application.requests.EmailPasswordAuthenticateRequest
import place.tomo.auth.application.requests.SignUpRequest
import place.tomo.auth.application.responses.LoginResponse
import place.tomo.auth.domain.services.AuthenticationService
import place.tomo.contract.ports.UserQueryPort

@Service
class AuthApplicationService(
    private val authenticateService: AuthenticationService,
    private val userQueryPort: UserQueryPort,
) {
    @Transactional
    fun signUp(request: SignUpRequest) {
        userQueryPort.createUser(request.email, request.password, request.name)

        // TODO: email 인증 번호 저장
        // TODO: email 인증 발송
    }

    fun authenticate(request: EmailPasswordAuthenticateRequest): LoginResponse {
        val authToken = authenticateService.authenticateEmailPassword(request.email, request.password)

        return LoginResponse(token = authToken.accessToken, refreshToken = authToken.refreshToken)
    }
}
