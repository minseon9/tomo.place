package place.tomo.common.user

data class UserContext(
    val userId: Long,
    val email: String,
    val name: String,
) {
    companion object {
        fun from(
            userId: Long,
            email: String,
            name: String,
        ): UserContext =
            UserContext(
                userId = userId,
                email = email,
                name = name,
            )
    }
}
