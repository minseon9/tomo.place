package place.tomo.contract.dtos

data class AuthorizedUserDTO(
    val id: Long,
    val email: String,
    val entityId: String,
)
