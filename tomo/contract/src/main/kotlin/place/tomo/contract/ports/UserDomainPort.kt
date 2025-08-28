package place.tomo.contract.ports

import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.vo.UserId

interface UserDomainPort {
    fun findActiveByEmail(email: String): UserInfoDTO?

    fun findByEmail(email: String): UserInfoDTO?

    fun create(
        email: String,
        name: String?,
    ): UserInfoDTO

    fun getOrCreate(
        email: String,
        name: String?,
    ): UserInfoDTO

    fun softDelete(userId: UserId)
}
