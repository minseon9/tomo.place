package place.tomo.user.domain.entities

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("UserEntity 단위 테스트")
class UserEntityTest {
    @Nested
    @DisplayName("create")
    inner class Create {
        @Test
        @DisplayName("유효한 이메일과 이름으로 엔티티를 생성한다")
        fun `create user entity when email and name valid expect entity created`() {
        }

        @Test
        @DisplayName("이메일 형식이 올바르지 않으면 BAD_REQUEST 예외를 던진다")
        fun `create user entity when email invalid expect 400 bad request`() {
        }

        @Test
        @DisplayName("이름이 비어있으면 BAD_REQUEST 예외를 던진다")
        fun `create user entity when name blank expect 400 bad request`() {
        }
    }
}
