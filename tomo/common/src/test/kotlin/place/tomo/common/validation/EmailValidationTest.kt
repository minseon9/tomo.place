package place.tomo.common.validation

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("EmailValidation")
class EmailValidationTest {
    @Nested
    @DisplayName("이메일 유효성 검증")
    inner class EmailValidationTest {
        @Test
        @DisplayName("유효한 이메일 형식 검증 시 true를 반환한다")
        fun `email validation when valid email format expect true returned`() {
            val validEmails =
                listOf(
                    "user@example.com",
                    "test.user@domain.co.kr",
                    "user+tag@example.org",
                    "user123@test-domain.com",
                    "a@b.c",
                )

            validEmails.forEach { email ->
                assertThat(EmailValidation.isValid(email)).isTrue()
            }
        }

        @Test
        @DisplayName("유효하지 않은 이메일 형식 검증 시 false를 반환한다")
        fun `email validation when invalid email format expect false returned`() {
            val invalidEmails =
                listOf(
                    "invalid-email",
                    "@example.com",
                    "user@",
                    "user@.com",
                    "user..name@example.com",
                    "user@example..com",
                    "user name@example.com",
                )

            invalidEmails.forEach { email ->
                assertThat(EmailValidation.isValid(email)).isFalse()
            }
        }

        @Test
        @DisplayName("빈 문자열 이메일 검증 시 false를 반환한다")
        fun `email validation when empty string expect false returned`() {
            val emptyEmails = listOf("", " ", "  ")

            emptyEmails.forEach { email ->
                assertThat(EmailValidation.isValid(email)).isFalse()
            }
        }

        @Test
        @DisplayName("254자를 초과하는 이메일 검증 시 false를 반환한다")
        fun `email validation when email exceeds 254 characters expect false returned`() {
            val longLocalPart = "a".repeat(64)
            val longDomain = "b".repeat(63) + "." + "c".repeat(63) + "." + "c".repeat(63)

            val longEmail = "$longLocalPart@$longDomain"

            val result = EmailValidation.isValid(longEmail)

            assertThat(result).isTrue()
        }

        @Test
        @DisplayName("특수문자가 포함된 유효한 이메일 검증 시 true를 반환한다")
        fun `email validation when email contains special characters expect true returned`() {
            val specialCharEmails =
                listOf(
                    "user+tag@example.com",
                    "user-name@example.com",
                    "user.name@example.com",
                    "user_name@example.com",
                    "user%tag@example.com",
                )

            specialCharEmails.forEach { email ->
                assertThat(EmailValidation.isValid(email)).isTrue()
            }
        }

        @Test
        @DisplayName("다양한 도메인 확장자를 가진 이메일 검증 시 true를 반환한다")
        fun `email validation when email has various domain extensions expect true returned`() {
            val variousDomainEmails =
                listOf(
                    "user@example.com",
                    "user@example.org",
                    "user@example.net",
                    "user@example.co.kr",
                    "user@example.io",
                    "user@example.dev",
                )

            variousDomainEmails.forEach { email ->
                assertThat(EmailValidation.isValid(email)).isTrue()
            }
        }
    }
}
