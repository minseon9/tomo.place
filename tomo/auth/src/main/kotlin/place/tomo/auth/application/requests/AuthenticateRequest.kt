package place.tomo.auth.application.requests

data class EmailPasswordAuthenticateRequest(
    val email: String,
    val password: String,
)
