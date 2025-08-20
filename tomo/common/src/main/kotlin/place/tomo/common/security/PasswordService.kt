package place.tomo.common.security

import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Component
import place.tomo.common.validation.password.PasswordPolicy
import place.tomo.common.validation.password.PasswordValidator
import place.tomo.common.validation.password.ValidationResult

interface PasswordService {
    fun getPasswordPolicies(): List<PasswordPolicy>

    fun validate(password: String): ValidationResult

    fun encode(rawPassword: String): String

    fun matches(
        rawPassword: String,
        encodedPassword: String,
    ): Boolean
}

@Component
class PasswordServiceImpl(
    private val passwordValidator: PasswordValidator,
    private val passwordEncoder: PasswordEncoder,
) : PasswordService {
    override fun getPasswordPolicies(): List<PasswordPolicy> = passwordValidator.getPasswordPolicies()

    override fun validate(password: String): ValidationResult = passwordValidator.validate(password)

    override fun encode(rawPassword: String): String = passwordEncoder.encode(rawPassword)

    override fun matches(
        rawPassword: String,
        encodedPassword: String,
    ): Boolean = passwordEncoder.matches(rawPassword, encodedPassword)
}
