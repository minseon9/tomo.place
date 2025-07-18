package dev.ian.mapa.application.commands

data class LoginCommand(
    val email: String,
    val password: String,
)
