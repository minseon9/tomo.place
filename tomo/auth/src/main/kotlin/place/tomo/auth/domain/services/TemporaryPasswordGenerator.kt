package place.tomo.auth.domain.services

import org.springframework.stereotype.Component
import place.tomo.common.exception.HttpErrorStatus
import place.tomo.common.exception.HttpException
import place.tomo.common.validation.password.LengthPolicy
import place.tomo.common.validation.password.PasswordValidator
import java.security.SecureRandom

@Component
class TemporaryPasswordGenerator(
    private val passwordValidator: PasswordValidator,
    private val lengthPolicy: LengthPolicy,
) {
    private val secureRandom: SecureRandom = SecureRandom()

    fun generate(): String {
        val targetLength = lengthPolicy.getMaxLength()
        val temporaryPassword = generatePassword(targetLength)

        if (!passwordValidator.validate(temporaryPassword).isValid) {
            throw HttpException(
                HttpErrorStatus.BAD_REQUEST,
                "비밀번호는 8자 이상이며 대문자, 소문자, 숫자, 특수문자를 포함해야 합니다.",
            )
        }

        return temporaryPassword
    }

    private fun generatePassword(length: Int): String {
        val requiredChars: List<Char> =
            passwordValidator.getPasswordPolicies().mapNotNull { policy ->
                val sample: List<Char> = policy.getSampleCharacters()

                if (sample.isNotEmpty()) {
                    null
                } else {
                    getRandom(sample)
                }
            }

        val allPossibleChars: List<Char> =
            passwordValidator
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
