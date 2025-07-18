package dev.ian.mapa.application.services

import dev.ian.mapa.domain.services.MemberDomainService
import org.springframework.stereotype.Service

@Service
class MemberApplicationService(
    private val memberDomainService: MemberDomainService,
) {
    fun createMember(
        email: String,
        password: String,
        name: String,
    ) {
        memberDomainService.createMember(email, password, name)
    }
}
