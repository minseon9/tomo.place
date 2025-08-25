package place.tomo.auth.application.services

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("OIDCApplicationService 단위 테스트")
class OIDCApplicationServiceTest {
    @Nested
    @DisplayName("signUp(oidc)")
    inner class SignUpWithOIDC {
        @Test
        @DisplayName("OIDC 사용자 정보 조회 후 기존 사용자가 있으면 생성하지 않는다")
        fun `sign up when user already exists expect do not create`() {
        }

        @Test
        @DisplayName("기존 사용자가 없으면 임시 비밀번호를 생성하여 유저를 생성한다")
        fun `sign up when user not exists expect temporary password generated and user created`() {
        }

        @Test
        @DisplayName("소셜 계정 연결을 요청한다 (linkSocialAccount)")
        fun `sign up when user found expect link social account`() {
        }

        @Test
        @DisplayName("토큰을 발급하여 LoginResponse로 반환한다")
        fun `sign up when completed expect login response with tokens`() {
        }
    }

    @Nested
    @DisplayName("authenticate(oidc)")
    inner class AuthenticateWithOIDC {
        @Test
        @DisplayName("인증 성공 시 토큰을 반환한다")
        fun `authenticate oidc when authorization code valid expect tokens returned`() {
        }

        @Test
        @DisplayName("연결되지 않은 소셜 계정일 경우 접근 거부 예외를 전달한다")
        fun `authenticate oidc when social account inactive or missing expect 403 forbidden`() {
        }
    }
}
