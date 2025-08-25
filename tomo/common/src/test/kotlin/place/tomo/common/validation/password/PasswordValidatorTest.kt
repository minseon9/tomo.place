package place.tomo.common.validation.password

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("PasswordValidator")
class PasswordValidatorTest {
    private lateinit var lengthPolicy: LengthPolicy
    private lateinit var uppercasePolicy: UppercasePolicy
    private lateinit var lowercasePolicy: LowercasePolicy
    private lateinit var digitPolicy: DigitPolicy
    private lateinit var specialCharPolicy: SpecialCharacterPolicy
    private lateinit var passwordValidator: PasswordValidatorImpl

    @BeforeEach
    fun setUp() {
        lengthPolicy = LengthPolicy()
        uppercasePolicy = UppercasePolicy()
        lowercasePolicy = LowercasePolicy()
        digitPolicy = DigitPolicy()
        specialCharPolicy = SpecialCharacterPolicy()
        passwordValidator =
            PasswordValidatorImpl(
                listOf(lengthPolicy, uppercasePolicy, lowercasePolicy, digitPolicy, specialCharPolicy),
            )
    }

    @Nested
    @DisplayName("비밀번호 정책 조회")
    inner class GetPasswordPolicies {
        @Test
        @DisplayName("설정된 모든 비밀번호 정책을 반환한다")
        fun `get password policies when configured expect all policies returned`() {
            val policies = passwordValidator.getPasswordPolicies()

            assertThat(policies).hasSize(5)
            assertThat(policies).anyMatch { it is LengthPolicy }
            assertThat(policies).anyMatch { it is UppercasePolicy }
            assertThat(policies).anyMatch { it is LowercasePolicy }
            assertThat(policies).anyMatch { it is DigitPolicy }
            assertThat(policies).anyMatch { it is SpecialCharacterPolicy }
        }
    }

    @Nested
    @DisplayName("비밀번호 검증")
    inner class ValidatePassword {
        @Test
        @DisplayName("모든 정책을 만족하는 비밀번호 검증 시 성공 결과를 반환한다")
        fun `validate password when all policies satisfied expect success result`() {
            val password = "ValidPass123!"

            val result = passwordValidator.validate(password)

            assertThat(result.isValid).isTrue()
            assertThat(result.violations).isEmpty()
        }

        @Test
        @DisplayName("길이 정책을 위반하는 비밀번호 검증 시 실패 결과를 반환한다")
        fun `validate password when length policy violated expect failure result`() {
            val password = "Short1!"

            val result = passwordValidator.validate(password)

            assertThat(result.isValid).isFalse()
            assertThat(result.violations).contains("비밀번호 길이는 8~20자")
        }

        @Test
        @DisplayName("대문자 정책을 위반하는 비밀번호 검증 시 실패 결과를 반환한다")
        fun `validate password when uppercase policy violated expect failure result`() {
            val password = "validpass123!"

            val result = passwordValidator.validate(password)

            assertThat(result.isValid).isFalse()
            assertThat(result.violations).contains("영문 대문자 최소 1개")
        }

        @Test
        @DisplayName("소문자 정책을 위반하는 비밀번호 검증 시 실패 결과를 반환한다")
        fun `validate password when lowercase policy violated expect failure result`() {
            val password = "VALIDPASS123!"

            val result = passwordValidator.validate(password)

            assertThat(result.isValid).isFalse()
            assertThat(result.violations).contains("영문 소문자 최소 1개")
        }

        @Test
        @DisplayName("숫자 정책을 위반하는 비밀번호 검증 시 실패 결과를 반환한다")
        fun `validate password when digit policy violated expect failure result`() {
            val password = "ValidPass!"

            val result = passwordValidator.validate(password)

            assertThat(result.isValid).isFalse()
            assertThat(result.violations).contains("숫자 최소 1개")
        }

        @Test
        @DisplayName("특수문자 정책을 위반하는 비밀번호 검증 시 실패 결과를 반환한다")
        fun `validate password when special character policy violated expect failure result`() {
            val password = "ValidPass123"

            val result = passwordValidator.validate(password)

            assertThat(result.isValid).isFalse()
            assertThat(result.violations).contains("특수문자 최소 1개")
        }

        @Test
        @DisplayName("여러 정책을 위반하는 비밀번호 검증 시 모든 위반 사항을 반환한다")
        fun `validate password when multiple policies violated expect all violations returned`() {
            val password = ""

            val result = passwordValidator.validate(password)

            assertThat(result.isValid).isFalse()
            assertThat(result.violations).hasSize(5)
            assertThat(result.violations).contains("비밀번호 길이는 8~20자")
            assertThat(result.violations).contains("영문 대문자 최소 1개")
            assertThat(result.violations).contains("영문 소문자 최소 1개")
            assertThat(result.violations).contains("숫자 최소 1개")
            assertThat(result.violations).contains("특수문자 최소 1개")
        }
    }
}
