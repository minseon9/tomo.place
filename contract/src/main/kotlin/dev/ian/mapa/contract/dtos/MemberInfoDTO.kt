package dev.ian.mapa.contract.dtos

data class MemberInfoDTO(
    val id: Long,
    val email: String,
    val password: String,
    val name: String,
)
