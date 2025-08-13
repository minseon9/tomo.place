package place.tomo.auth.ui.controllers

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("OIDCController 단위 테스트")
class OIDCControllerTest {
    @Nested
    @DisplayName("POST /api/oidc/signup")
    inner class SignUpWithOIDC {
        @Test
        @DisplayName("인가 코드와 공급자를 받아 회원가입 후 토큰을 반환한다")
        fun `sign up when authorization code valid expect 200 with tokens`() {
        }

        @Test
        @DisplayName("잘못된 인가 코드일 경우 에러를 매핑한다")
        fun `sign up when authorization code invalid expect 400 bad request`() {
        }
    }

    @Nested
    @DisplayName("POST /api/oidc/login")
    inner class LoginWithOIDC {
        @Test
        @DisplayName("인가 코드로 인증 성공 시 토큰을 반환한다")
        fun `login when authorization code valid expect 200 with tokens`() {
        }

        @Test
        @DisplayName("연결되지 않은 소셜계정일 경우 접근 거부 에러를 매핑한다")
        fun `login when social account not linked expect 403 forbidden`() {
        }
    }
}
