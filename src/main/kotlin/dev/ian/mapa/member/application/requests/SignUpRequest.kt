package dev.ian.mapa.member.application.requests


data class SignUpRequest(
    val name: String,
    val email: String,
    val password: String
)