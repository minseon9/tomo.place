package dev.ian.mapa.auth.ui.requests

data class SignUpRequestBody(
    val email: String,
    val password: String,
    val name: String,
)
