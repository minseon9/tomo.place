package place.tomo.contract.ports

import place.tomo.contract.vo.UserId

interface UserCommandPort {
    fun create(email: String, rawPassword: String?, name: String?): UserId
    fun softDelete(userId: UserId)
}


