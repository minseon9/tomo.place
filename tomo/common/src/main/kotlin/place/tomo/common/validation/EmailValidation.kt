package place.tomo.common.validation

object EmailValidation {
    private val emailRegex =
        Regex(
            pattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$",
        )

    fun isValid(email: String): Boolean {
        if (email.isBlank()) return false
        if (email.length > 254) return false

        return emailRegex.matches(email)
    }
}
