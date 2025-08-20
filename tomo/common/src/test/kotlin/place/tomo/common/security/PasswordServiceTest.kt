package place.tomo.common.security

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.security.crypto.password.PasswordEncoder
import place.tomo.common.validation.password.PasswordPolicy
import place.tomo.common.validation.password.PasswordValidator
import place.tomo.common.validation.password.ValidationResult

@DisplayName("PasswordService")
class PasswordServiceTest {
    private lateinit var passwordValidator: PasswordValidator
    private lateinit var passwordEncoder: PasswordEncoder
    private lateinit var passwordService: PasswordServiceImpl

    @BeforeEach
    fun setUp() {
        passwordValidator = mockk()
        passwordEncoder = mockk()
        passwordService = PasswordServiceImpl(passwordValidator, passwordEncoder)
    }

    @Nested
    @DisplayName("비밀번호 정책 조회")
    inner class GetPasswordPolicies {
        @Test
        @DisplayName("PasswordValidator에서 비밀번호 정책 목록을 반환한다")
        fun `get password policies when invoked expect policies from validator`() {
            val policies = listOf(mockk<PasswordPolicy>(), mockk<PasswordPolicy>())
            every { passwordValidator.getPasswordPolicies() } returns policies

            val result = passwordService.getPasswordPolicies()

            assertThat(result).isEqualTo(policies)
            verify { passwordValidator.getPasswordPolicies() }
        }
    }

    @Nested
    @DisplayName("비밀번호 검증")
    inner class ValidatePassword {
        @Test
        @DisplayName("유효한 비밀번호 검증 시 성공 결과를 반환한다")
        fun `validate password when valid expect success result`() {
            val password = "ValidPass123!"
            val validationResult = ValidationResult(isValid = true)
            every { passwordValidator.validate(password) } returns validationResult

            val result = passwordService.validate(password)

            assertThat(result).isEqualTo(validationResult)
            verify { passwordValidator.validate(password) }
        }

        @Test
        @DisplayName("유효하지 않은 비밀번호 검증 시 실패 결과를 반환한다")
        fun `validate password when invalid expect failure result`() {
            val password = "weak"
            val validationResult = ValidationResult(isValid = false, violations = listOf("길이 부족"))
            every { passwordValidator.validate(password) } returns validationResult

            val result = passwordService.validate(password)

            assertThat(result).isEqualTo(validationResult)
            assertThat(result.isValid).isFalse()
            assertThat(result.violations).contains("길이 부족")
            verify { passwordValidator.validate(password) }
        }
    }

    @Nested
    @DisplayName("비밀번호 인코딩")
    inner class EncodePassword {
        @Test
        @DisplayName("원본 비밀번호를 인코딩하여 해시된 문자열을 반환한다")
        fun `encode password when raw password provided expect hashed string returned`() {
            val rawPassword = "MyPassword123!"
            val hashedPassword = "hashed_password_string"
            every { passwordEncoder.encode(rawPassword) } returns hashedPassword

            val result = passwordService.encode(rawPassword)

            assertThat(result).isEqualTo(hashedPassword)
            verify { passwordEncoder.encode(rawPassword) }
        }
    }

    @Nested
    @DisplayName("비밀번호 매칭")
    inner class MatchesPassword {
        @Test
        @DisplayName("일치하는 원본 비밀번호와 해시된 비밀번호로 매칭 시 true를 반환한다")
        fun `matches password when raw matches encoded expect true returned`() {
            val rawPassword = "MyPassword123!"
            val encodedPassword = "hashed_password_string"
            every { passwordEncoder.matches(rawPassword, encodedPassword) } returns true

            val result = passwordService.matches(rawPassword, encodedPassword)

            assertThat(result).isTrue()
            verify { passwordEncoder.matches(rawPassword, encodedPassword) }
        }

        @Test
        @DisplayName("일치하지 않는 원본 비밀번호와 해시된 비밀번호로 매칭 시 false를 반환한다")
        fun `matches password when raw not matches encoded expect false returned`() {
            val rawPassword = "WrongPassword123!"
            val encodedPassword = "hashed_password_string"
            every { passwordEncoder.matches(rawPassword, encodedPassword) } returns false

            val result = passwordService.matches(rawPassword, encodedPassword)

            assertThat(result).isFalse()
            verify { passwordEncoder.matches(rawPassword, encodedPassword) }
        }
    }
}
