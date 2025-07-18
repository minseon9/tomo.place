package dev.ian.mapa.infra.adapter

import dev.ian.mapa.contract.dtos.MemberInfoDTO
import dev.ian.mapa.contract.ports.MemberQueryPort
import dev.ian.mapa.domain.services.MemberDomainService
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
