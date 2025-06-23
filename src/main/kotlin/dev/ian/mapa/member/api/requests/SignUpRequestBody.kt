package dev.ian.mapa.member.api.requests


data class SignUpRequestBody(
    val name: String,
    val email: String,
    val password: String
)