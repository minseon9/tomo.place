package dev.ian.mapa.ui.requests

data class SignUpRequestBody(
    val email: String,
    val password: String,
    val name: String,
)
