package dev.ian.mapa.contract.ports

import dev.ian.mapa.contract.dtos.MemberInfoDTO

interface MemberQueryPort {
    fun findByEmail(email: String): MemberInfoDTO?

    fun createMember(
        email: String,
        password: String,
        name: String,
    ): MemberInfoDTO
}
