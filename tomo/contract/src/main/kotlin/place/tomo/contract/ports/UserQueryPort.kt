package place.tomo.contract.ports

import place.tomo.contract.dtos.UserInfoDTO

interface UserQueryPort {
    fun findByEmail(email: String): UserInfoDTO?

    // FIXME: UserInfoDTO로 통신하도록 수정
    fun createUser(
        email: String,
        password: String,
        name: String,
    )
}
