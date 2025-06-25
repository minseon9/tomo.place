package dev.ian.mapa.application.requests


data class SignUpRequest(
    val email: String,
    val password: String,
    val name: String,
)