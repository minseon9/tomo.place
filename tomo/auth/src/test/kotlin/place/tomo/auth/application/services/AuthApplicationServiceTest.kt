package place.tomo.auth.application.services

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("AuthApplicationService 단위 테스트")
class AuthApplicationServiceTest {
    @Nested
    @DisplayName("signUp")
    inner class SignUp {
        @Test
        @DisplayName("UserDomainPort.create를 호출하여 사용자를 생성한다")
        fun `sign up when valid request expect user created via domain port`() {
        }
    }

    @Nested
    @DisplayName("authenticate(email/password)")
    inner class AuthenticateEmailPassword {
        @Test
        @DisplayName("이메일/비밀번호 인증 성공 시 토큰 DTO를 LoginResponse로 변환해 반환한다")
        fun `authenticate when email and password valid expect login response returned`() {
        }

        @Test
        @DisplayName("인증 실패 예외를 그대로 전달한다")
        fun `authenticate when email or password invalid expect throws unauthorized`() {
        }
    }
}
