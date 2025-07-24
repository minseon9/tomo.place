package place.tomo.contract.dtos

data class MemberInfoDTO(
    val id: Long,
    val email: String,
    val password: String,
    val name: String,
)
