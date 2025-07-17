package dev.ian.mapa.application.services

import SignUpCommand
import dev.ian.mapa.domain.services.MemberDomainService
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class MemberApplicationService(
    private val memberDomainService: MemberDomainService,
) {
    @Transactional
    fun signUp(command: SignUpCommand) {
        memberDomainService.signUp(command.email, command.password, command.name)

        return
    }
}
