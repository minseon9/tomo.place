package place.tomo.common.validation.password

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("PasswordPolicy")
class PasswordPolicyTest {
    @Nested
    @DisplayName("LengthPolicy")
    inner class LengthPolicyTest {
        private val policy = LengthPolicy()

        @Test
        @DisplayName("8~20자 길이의 비밀번호 검증 시 true를 반환한다")
        fun `length policy when password length valid expect true returned`() {
            val validPasswords = listOf("12345678", "ValidPass123!", "VeryLongPassword123!")

            validPasswords.forEach { password ->
                assertThat(policy.isSatisfied(password)).isTrue()
            }
        }

        @Test
        @DisplayName("8자 미만 또는 20자 초과 비밀번호 검증 시 false를 반환한다")
        fun `length policy when password length invalid expect false returned`() {
            val invalidPasswords = listOf("1234567", "VeryVeryLongPassword123!")

            invalidPasswords.forEach { password ->
                assertThat(policy.isSatisfied(password)).isFalse()
            }
        }

        @Test
        @DisplayName("LengthPolicy의 description이 올바르게 설정된다")
        fun `length policy description when accessed expect correct description`() {
            val description = policy.description

            assertThat(description).isEqualTo("비밀번호 길이는 8~20자")
        }

        @Test
        @DisplayName("LengthPolicy의 getMaxLength가 20을 반환한다")
        fun `length policy get max length when invoked expect 20 returned`() {
            val maxLength = policy.getMaxLength()

            assertThat(maxLength).isEqualTo(20)
        }
    }

    @Nested
    @DisplayName("UppercasePolicy")
    inner class UppercasePolicyTest {
        private val policy = UppercasePolicy()

        @Test
        @DisplayName("대문자가 포함된 비밀번호 검증 시 true를 반환한다")
        fun `uppercase policy when password contains uppercase expect true returned`() {
            val validPasswords = listOf("ValidPass123!", "ABC123", "MixedCase123")

            validPasswords.forEach { password ->
                assertThat(policy.isSatisfied(password)).isTrue()
            }
        }

        @Test
        @DisplayName("대문자가 없는 비밀번호 검증 시 false를 반환한다")
        fun `uppercase policy when password no uppercase expect false returned`() {
            val invalidPasswords = listOf("validpass123!", "123456", "lowercase")

            invalidPasswords.forEach { password ->
                assertThat(policy.isSatisfied(password)).isFalse()
            }
        }

        @Test
        @DisplayName("UppercasePolicy의 description이 올바르게 설정된다")
        fun `uppercase policy description when accessed expect correct description`() {
            val description = policy.description

            assertThat(description).isEqualTo("영문 대문자 최소 1개")
        }

        @Test
        @DisplayName("UppercasePolicy의 getSampleCharacters가 A-Z를 반환한다")
        fun `uppercase policy get sample characters when invoked expect a to z returned`() {
            val sampleChars = policy.getSampleCharacters()

            assertThat(sampleChars).containsExactlyElementsOf(('A'..'Z').toList())
        }
    }

    @Nested
    @DisplayName("LowercasePolicy")
    inner class LowercasePolicyTest {
        private val policy = LowercasePolicy()

        @Test
        @DisplayName("소문자가 포함된 비밀번호 검증 시 true를 반환한다")
        fun `lowercase policy when password contains lowercase expect true returned`() {
            val validPasswords = listOf("ValidPass123!", "abc123", "MixedCase123")

            validPasswords.forEach { password ->
                assertThat(policy.isSatisfied(password)).isTrue()
            }
        }

        @Test
        @DisplayName("소문자가 없는 비밀번호 검증 시 false를 반환한다")
        fun `lowercase policy when password no lowercase expect false returned`() {
            val invalidPasswords = listOf("VALIDPASS123!", "123456", "UPPERCASE")

            invalidPasswords.forEach { password ->
                assertThat(policy.isSatisfied(password)).isFalse()
            }
        }

        @Test
        @DisplayName("LowercasePolicy의 description이 올바르게 설정된다")
        fun `lowercase policy description when accessed expect correct description`() {
            val description = policy.description

            assertThat(description).isEqualTo("영문 소문자 최소 1개")
        }

        @Test
        @DisplayName("LowercasePolicy의 getSampleCharacters가 a-z를 반환한다")
        fun `lowercase policy get sample characters when invoked expect a to z returned`() {
            val sampleChars = policy.getSampleCharacters()

            assertThat(sampleChars).containsExactlyElementsOf(('a'..'z').toList())
        }
    }

    @Nested
    @DisplayName("DigitPolicy")
    inner class DigitPolicyTest {
        private val policy = DigitPolicy()

        @Test
        @DisplayName("숫자가 포함된 비밀번호 검증 시 true를 반환한다")
        fun `digit policy when password contains digit expect true returned`() {
            val validPasswords = listOf("ValidPass123!", "abc123", "123456")

            validPasswords.forEach { password ->
                assertThat(policy.isSatisfied(password)).isTrue()
            }
        }

        @Test
        @DisplayName("숫자가 없는 비밀번호 검증 시 false를 반환한다")
        fun `digit policy when password no digit expect false returned`() {
            val invalidPasswords = listOf("ValidPass!", "abcdef", "UPPERCASE")

            invalidPasswords.forEach { password ->
                assertThat(policy.isSatisfied(password)).isFalse()
            }
        }

        @Test
        @DisplayName("DigitPolicy의 description이 올바르게 설정된다")
        fun `digit policy description when accessed expect correct description`() {
            val description = policy.description

            assertThat(description).isEqualTo("숫자 최소 1개")
        }

        @Test
        @DisplayName("DigitPolicy의 getSampleCharacters가 0-9를 반환한다")
        fun `digit policy get sample characters when invoked expect 0 to 9 returned`() {
            val sampleChars = policy.getSampleCharacters()

            assertThat(sampleChars).containsExactlyElementsOf(('0'..'9').toList())
        }
    }

    @Nested
    @DisplayName("SpecialCharacterPolicy")
    inner class SpecialCharacterPolicyTest {
        private val policy = SpecialCharacterPolicy()

        @Test
        @DisplayName("특수문자가 포함된 비밀번호 검증 시 true를 반환한다")
        fun `special character policy when password contains special char expect true returned`() {
            val validPasswords = listOf("ValidPass123!", "abc@123", "test#pass")

            validPasswords.forEach { password ->
                assertThat(policy.isSatisfied(password)).isTrue()
            }
        }

        @Test
        @DisplayName("특수문자가 없는 비밀번호 검증 시 false를 반환한다")
        fun `special character policy when password no special char expect false returned`() {
            val invalidPasswords = listOf("ValidPass123", "abcdef", "123456")

            invalidPasswords.forEach { password ->
                assertThat(policy.isSatisfied(password)).isFalse()
            }
        }

        @Test
        @DisplayName("SpecialCharacterPolicy의 description이 올바르게 설정된다")
        fun `special character policy description when accessed expect correct description`() {
            val description = policy.description

            assertThat(description).isEqualTo("특수문자 최소 1개")
        }

        @Test
        @DisplayName("SpecialCharacterPolicy의 getSampleCharacters가 특수문자 목록을 반환한다")
        fun `special character policy get sample characters when invoked expect special chars returned`() {
            val sampleChars = policy.getSampleCharacters()

            assertThat(
                sampleChars,
            ).contains(
                '!',
                '@',
                '#',
                '$',
                '%',
                '^',
                '&',
                '*',
                '(',
                ')',
                '-',
                '_',
                '=',
                '+',
                '[',
                ']',
                '{',
                '}',
                ';',
                ':',
                ',',
                '.',
                '/',
                '?',
            )
        }
    }
}
