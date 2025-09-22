package place.tomo.contract.ports

import place.tomo.contract.dtos.UserInfoDTO

interface UserDomainPort {
    fun findActiveByEntityId(entityId: String): UserInfoDTO?

    fun getOrCreateActiveUser(
        email: String,
        name: String?,
    ): UserInfoDTO

    fun softDelete(userId: Long)
}
