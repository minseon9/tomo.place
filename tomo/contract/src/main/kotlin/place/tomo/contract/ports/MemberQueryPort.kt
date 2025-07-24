package place.tomo.contract.ports

import place.tomo.contract.dtos.MemberInfoDTO

interface MemberQueryPort {
    fun findByEmail(email: String): MemberInfoDTO?
    
    fun findById(id: Long): MemberInfoDTO?

    fun createMember(
        email: String,
        password: String,
        name: String,
    ): MemberInfoDTO
}
