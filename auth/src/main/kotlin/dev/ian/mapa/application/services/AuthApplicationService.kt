package dev.ian.mapa.application.services

import dev.ian.mapa.application.commands.LoginCommand
import dev.ian.mapa.auth.application.commands.SignUpCommand
import dev.ian.mapa.contract.ports.MemberQueryPort
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class AuthApplicationService(
    private val authenticationManager: AuthenticationManager,
    private val jwtProvider: JwtTokenProvider,
    private val memberQueryPort: MemberQueryPort,
) {
    @Transactional
    fun signUp(command: SignUpCommand) {
        memberQueryPort.createMember(command.email, command.password, command.name)
    }

    fun login(command: LoginCommand): String {
        val authentication =
            authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken(command.email, command.password),
            )

        val email = authentication.name
        return jwtProvider.issueToken(email)
    }
}
