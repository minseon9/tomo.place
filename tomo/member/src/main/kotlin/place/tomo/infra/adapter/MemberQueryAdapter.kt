package place.tomo.infra.adapter

import place.tomo.contract.dtos.MemberInfoDTO
import place.tomo.contract.ports.MemberQueryPort
import place.tomo.domain.services.MemberDomainService
import org.springframework.stereotype.Component

@Component
class MemberQueryAdapter(
    private val memberService: MemberDomainService,
) : MemberQueryPort {
    override fun findByEmail(email: String): MemberInfoDTO? {
        val member = memberService.findByEmail(email) ?: return null

        return MemberInfoDTO(
            id = member.id,
            email = member.email,
            password = member.password,
            name = member.username,
        )
    }

    override fun createMember(
        email: String,
        password: String,
        name: String,
    ): MemberInfoDTO {
        val member = memberService.createMember(email, password, name)

        return MemberInfoDTO(
            id = member.id,
            email = member.email,
            password = member.password,
            name = member.username,
        )
    }
}
