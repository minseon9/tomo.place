package place.tomo.user.domain.entities

import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import place.tomo.user.domain.constant.UserStatus
import place.tomo.user.domain.exception.InvalidEmailException
import place.tomo.user.domain.exception.InvalidUsernameException

@DisplayName("UserEntity")
class UserEntityTest {
    @Nested
    @DisplayName("사용자 엔티티 생성")
    inner class Create {
        @Test
        @DisplayName("유효한 이메일과 이름으로 사용자 엔티티를 생성한다")
        fun `create user entity when email and name valid expect entity created`() {
            val user =
                UserEntity.create(
                    email = "user@example.com",
                    password = HashedPassword("hashed"),
                    username = "Tomo",
                    status = UserStatus.ACTIVATED,
                )

            assertThat(user).isNotNull()
            assertThat(user.email).isEqualTo("user@example.com")
            assertThat(user.password.value).isEqualTo("hashed")
            assertThat(user.username).isEqualTo("Tomo")
            assertThat(user.status).isEqualTo(UserStatus.ACTIVATED)
        }

        @Test
        @DisplayName("잘못된 이메일 형식으로 사용자 엔티티 생성 시 예외를 던진다")
        fun `create user entity when email invalid expect exception`() {
            assertThatThrownBy {
                UserEntity.create(
                    email = "invalid-email",
                    password = HashedPassword("hashed"),
                    username = "Tomo",
                )
            }.isInstanceOf(InvalidEmailException::class.java)
                .extracting("status")
                .isEqualTo(HttpStatus.BAD_REQUEST)
        }

        @Test
        @DisplayName("빈 이름으로 사용자 엔티티 생성 시 예외를 던진다")
        fun `create user entity when name blank expect 400 bad request`() {
            assertThatThrownBy {
                UserEntity.create(
                    email = "user@example.com",
                    password = HashedPassword("hashed"),
                    username = "",
                )
            }.isInstanceOf(InvalidUsernameException::class.java)
                .extracting("status")
                .isEqualTo(HttpStatus.BAD_REQUEST)
        }
    }
}
