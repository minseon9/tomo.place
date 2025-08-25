package place.tomo.common.validation

import jakarta.validation.Validation
import jakarta.validation.Validator
import jakarta.validation.constraints.Email

object EmailValidation {
    private val validator: Validator = Validation.buildDefaultValidatorFactory().validator

    private data class EmailWrapper(
        @field:Email val email: String,
    )

    fun isValid(email: String): Boolean {
        if (email.isBlank()) return false

        val violations = validator.validate(EmailWrapper(email))

        return violations.isEmpty()
    }
}
