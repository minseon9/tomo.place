package place.tomo.common.validation.password

import org.springframework.stereotype.Component

data class ValidationResult(
    val isValid: Boolean,
    val violations: List<String> = emptyList(),
)

interface PasswordValidator {
    fun getPolicies(): List<PasswordPolicy>

    fun validate(password: String): ValidationResult
}

@Component
class PasswordValidatorImpl(
    val policies: List<PasswordPolicy>,
) : PasswordValidator {
    override fun getPolicies(): List<PasswordPolicy> = policies

    override fun validate(password: String): ValidationResult {
        val violations = mutableListOf<String>()

        for (requirement in policies) {
            if (!requirement.isSatisfied(password)) {
                violations.add(requirement.description)
            }
        }

        return ValidationResult(violations.isEmpty(), violations)
    }
}
