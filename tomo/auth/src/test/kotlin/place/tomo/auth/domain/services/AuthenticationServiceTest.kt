package place.tomo.auth.domain.services

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("AuthenticationService 단위 테스트")
class AuthenticationServiceTest {
    @Nested
    @DisplayName("authenticateEmailPassword")
    inner class EmailPasswordAuth {
        @Test
        @DisplayName("AuthenticationManager로 인증 성공 시 Access/Refresh 토큰을 발급한다")
        fun `authenticate email password when credentials valid expect access and refresh issued`() {
        }

        @Test
        @DisplayName("인증 실패 시 예외를 전달한다")
        fun `authenticate email password when credentials invalid expect throws`() {
        }
    }

    @Nested
    @DisplayName("authenticateOIDC")
    inner class OIDCAuth {
        @Test
        @DisplayName("소셜 계정이 활성 상태이면 토큰을 발급한다")
        fun `authenticate oidc when social account active expect tokens issued`() {
        }

        @Test
        @DisplayName("소셜 계정이 비활성 또는 미연결이면 FORBIDDEN을 던진다")
        fun `authenticate oidc when social account inactive or not linked expect 403 forbidden`() {
        }
    }

    @Nested
    @DisplayName("issueOIDCUserAuthToken")
    inner class IssueTokenForOIDCUser {
        @Test
        @DisplayName("이메일을 subject로 하여 Access/Refresh 토큰을 발급한다")
        fun `issue access token when oidc user info provided expect access and refresh issued`() {
        }
    }

    @Nested
    @DisplayName("getOidcUserInfo")
    inner class GetOidcUserInfo {
        @Test
        @DisplayName("ProviderFactory에서 서비스 획득 후 사용자 정보를 반환한다")
        fun `get oidc user info when provider and code valid expect user info returned`() {
        }
    }
}
