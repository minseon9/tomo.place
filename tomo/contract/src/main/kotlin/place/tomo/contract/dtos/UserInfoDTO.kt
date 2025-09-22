package place.tomo.contract.dtos

import java.util.UUID

data class UserInfoDTO(
    val id: Long,
    val entityId: UUID,
    val email: String,
    val name: String,
)
