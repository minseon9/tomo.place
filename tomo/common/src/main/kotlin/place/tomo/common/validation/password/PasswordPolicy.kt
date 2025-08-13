package place.tomo.common.validation.password

import org.springframework.stereotype.Component

interface PasswordPolicy {
    val description: String

    fun isSatisfied(password: String): Boolean

    fun getSampleCharacters(): List<Char>
}

@Component
class LengthPolicy : PasswordPolicy {
    override val description: String = "비밀번호 길이는 8~20자"
    private val minLength: Int = 8
    private val maxLength: Int = 20

    override fun isSatisfied(password: String): Boolean = password.length in minLength..maxLength

    override fun getSampleCharacters(): List<Char> = listOf()

    fun getMaxLength(): Int = maxLength
}

@Component
class UppercasePolicy : PasswordPolicy {
    override val description: String = "영문 대문자 최소 1개"

    override fun isSatisfied(password: String): Boolean = password.any { it.isUpperCase() && it.isLetter() }

    override fun getSampleCharacters(): List<Char> = ('A'..'Z').toList()
}

@Component
class LowercasePolicy : PasswordPolicy {
    override val description: String = "영문 소문자 최소 1개"

    override fun isSatisfied(password: String): Boolean = password.any { it.isLowerCase() && it.isLetter() }

    override fun getSampleCharacters(): List<Char> = ('a'..'z').toList()
}

@Component
class DigitPolicy : PasswordPolicy {
    override val description: String = "숫자 최소 1개"

    override fun isSatisfied(password: String): Boolean = password.any { it.isDigit() }

    override fun getSampleCharacters(): List<Char> = ('0'..'9').toList()
}

@Component
class SpecialCharacterPolicy : PasswordPolicy {
    private val specialChars: CharArray = "!@#\$%^&*()-_=+[]{};:,./?".toCharArray()

    override val description: String = "특수문자 최소 1개"

    override fun isSatisfied(password: String): Boolean = password.any { it in specialChars }

    override fun getSampleCharacters(): List<Char> = specialChars.toList()
}
