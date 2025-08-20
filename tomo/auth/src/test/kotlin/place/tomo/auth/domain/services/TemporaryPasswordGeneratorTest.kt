package place.tomo.auth.domain.services

import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import place.tomo.auth.domain.exception.InvalidTemporaryPasswordException
import place.tomo.common.security.PasswordService
import place.tomo.common.validation.password.DigitPolicy
import place.tomo.common.validation.password.LengthPolicy
import place.tomo.common.validation.password.LowercasePolicy
import place.tomo.common.validation.password.PasswordPolicy
import place.tomo.common.validation.password.PasswordValidatorImpl
import place.tomo.common.validation.password.SpecialCharacterPolicy
import place.tomo.common.validation.password.UppercasePolicy
import place.tomo.common.validation.password.ValidationResult

@DisplayName("TemporaryPasswordGenerator")
class TemporaryPasswordGeneratorTest {
    private val lengthPolicy: LengthPolicy = LengthPolicy()
    private val uppercasePolicy: UppercasePolicy = UppercasePolicy()
    private val lowercasePolicy: LowercasePolicy = LowercasePolicy()
    private val digitPolicy: DigitPolicy = DigitPolicy()
    private val specialCharPolicy: SpecialCharacterPolicy = SpecialCharacterPolicy()

    private lateinit var passwordService: PasswordService
    private lateinit var generator: TemporaryPasswordGenerator

    @BeforeEach
    fun setUp() {
        passwordService = mockk()
        every { passwordService.getPasswordPolicies() } returns
            listOf(lengthPolicy, uppercasePolicy, lowercasePolicy, digitPolicy, specialCharPolicy)

        generator = TemporaryPasswordGenerator(passwordService, lengthPolicy)
    }

    @Nested
    @DisplayName("임시 비밀번호 생성")
    inner class Generate {
        @Test
        @DisplayName("LengthPolicy의 최대 길이로 임시 비밀번호를 생성한다")
        fun `generate when invoked expect length equals max`() {
            every { passwordService.validate(any()) } returns ValidationResult(isValid = true)

            val result = generator.generate()

            assertThat(result).hasSize(lengthPolicy.getMaxLength())
        }

        @Test
        @DisplayName("모든 비밀번호 정책(대/소문자, 숫자, 특수문자)을 만족하는 임시 비밀번호를 생성한다")
        fun `generate when invoked expect satisfy all policies`() {
            every { passwordService.validate(any()) } returns ValidationResult(isValid = true)

            val result = generator.generate()

            assertThat(result).hasSize(lengthPolicy.getMaxLength())
            assertThat(result).matches(".*[A-Z].*")
            assertThat(result).matches(".*[a-z].*")
            assertThat(result).matches(".*[0-9].*")
            assertThat(result).matches(".*[!@#\$%^&*()\\-_=+\\[\\]{};:,./?].*")
        }

        @Test
        @DisplayName("정책에 부합하지 않는 임시 비밀번호가 생성되면 BAD_REQUEST 예외를 던진다")
        fun `generate when generated invalid expect 400 bad request`() {
            every { passwordService.validate(any()) } returns ValidationResult(isValid = false)

            assertThatThrownBy { generator.generate() }
                .isInstanceOf(InvalidTemporaryPasswordException::class.java)
                .extracting("status")
                .isEqualTo(HttpStatus.BAD_REQUEST)
        }
    }
}
