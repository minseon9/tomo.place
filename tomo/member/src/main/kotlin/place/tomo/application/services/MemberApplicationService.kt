package place.tomo.application.services

import place.tomo.domain.services.MemberDomainService
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
