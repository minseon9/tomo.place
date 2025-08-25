package place.tomo.user.domain.services

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("UserDomainService 단위 테스트")
class UserDomainServiceTest {
    @Nested
    @DisplayName("createUser")
    inner class CreateUser {
        @Test
        @DisplayName("중복 이메일이 없고 비밀번호가 유효하면 사용자 생성에 성공한다")
        fun `create user when email unique and password valid expect entity created`() {
        }

        @Test
        @DisplayName("이미 존재하는 이메일이면 CONFLICT 예외를 던진다")
        fun `create user when email duplicated expect 409 conflict`() {
        }

        @Test
        @DisplayName("비밀번호 정책을 만족하지 못하면 BAD_REQUEST 예외를 던진다")
        fun `create user when password policy violated expect 400 bad request`() {
        }
    }
}
