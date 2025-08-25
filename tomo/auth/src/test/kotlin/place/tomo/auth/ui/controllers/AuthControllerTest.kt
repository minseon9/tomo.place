package place.tomo.auth.ui.controllers

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("AuthController 단위 테스트")
class AuthControllerTest {
    @Nested
    @DisplayName("POST /api/auth/signup")
    inner class SignUp {
        @Test
        @DisplayName("이메일/비밀번호/이름을 받아 서비스 SignUp 요청을 위임한다")
        fun `sign up when valid body expect service invoked`() {
        }

        @Test
        @DisplayName("요청 바디가 누락된 경우 400을 반환한다 (컨트롤러 레벨 검증)")
        fun `sign up when body missing expect 400 bad request`() {
        }
    }

    @Nested
    @DisplayName("POST /api/auth/login")
    inner class Login {
        @Test
        @DisplayName("이메일/비밀번호로 인증 후 토큰과 리프레시 토큰을 반환한다")
        fun `login when email and password valid expect 200 with tokens`() {
        }

        @Test
        @DisplayName("인증 실패 시 적절한 에러를 매핑한다")
        fun `login when authentication fails expect 401 unauthorized`() {
        }

        @Test
        @DisplayName("요청 바디가 누락된 경우 400을 반환한다 (컨트롤러 레벨 검증)")
        fun `login when body missing expect 400 bad request`() {
        }
    }
}
