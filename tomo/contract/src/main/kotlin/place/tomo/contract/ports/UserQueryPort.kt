package place.tomo.contract.ports

import place.tomo.contract.dtos.UserInfoDTO

interface UserQueryPort {
    fun findByEmail(email: String): UserInfoDTO?
}
