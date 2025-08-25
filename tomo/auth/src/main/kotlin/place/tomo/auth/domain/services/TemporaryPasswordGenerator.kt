package place.tomo.auth.domain.services

import org.springframework.stereotype.Component
import place.tomo.auth.domain.exception.InvalidTemporaryPasswordException
import place.tomo.common.security.PasswordService
import place.tomo.common.validation.password.LengthPolicy
import java.security.SecureRandom

@Component
class TemporaryPasswordGenerator(
    private val passwordService: PasswordService,
    private val lengthPolicy: LengthPolicy,
) {
    private val secureRandom: SecureRandom = SecureRandom()

    fun generate(): String {
        val targetLength = lengthPolicy.getMaxLength()
        val temporaryPassword = generatePassword(targetLength)

        if (!passwordService.validate(temporaryPassword).isValid) {
            throw InvalidTemporaryPasswordException("비밀번호는 8자 이상이며 대문자, 소문자, 숫자, 특수문자를 포함해야 합니다.")
        }

        return temporaryPassword
    }

    private fun generatePassword(length: Int): String {
        val requiredChars: List<Char> =
            passwordService.getPasswordPolicies().mapNotNull { policy ->
                val sample: List<Char> = policy.getSampleCharacters()
                if (sample.isNotEmpty()) getRandom(sample) else null
            }

        val allPossibleChars: List<Char> =
            passwordService
                .getPasswordPolicies()
                .flatMap { policy ->
                    policy.getSampleCharacters()
                }.distinct()
        val additionalCount = (length - requiredChars.size).coerceAtLeast(0)
        val additionalChars =
            List(additionalCount) {
                getRandom(allPossibleChars)
            }

        val allChars = (requiredChars + additionalChars).toMutableList()
        allChars.shuffle(secureRandom)

        return allChars.joinToString("")
    }

    private fun getRandom(chars: List<Char>): Char = chars[secureRandom.nextInt(chars.size)]
}
