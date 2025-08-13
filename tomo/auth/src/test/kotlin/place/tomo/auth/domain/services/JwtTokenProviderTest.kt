package place.tomo.auth.domain.services

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("JwtTokenProvider 단위 테스트")
class JwtTokenProviderTest {
    @Nested
    @DisplayName("issueAccessToken / issueRefreshToken")
    inner class IssueTokens {
        @Test
        @DisplayName("주어진 subject로 서명된 JWT를 발급한다")
        fun `issue access and refresh token when subject provided expect signed jwt generated`() {
        }

        @Test
        @DisplayName("Access/Refresh TTL이 다르게 적용된다")
        fun `issue tokens when subject provided expect different ttl applied`() {
        }
    }

    @Nested
    @DisplayName("validateToken / getUsernameFromToken")
    inner class ValidateAndParse {
        @Test
        @DisplayName("유효한 토큰은 true를 반환한다")
        fun `validate token when token valid expect true returned`() {
        }

        @Test
        @DisplayName("손상된 토큰은 false를 반환한다")
        fun `validate token when token invalid expect false returned`() {
        }

        @Test
        @DisplayName("토큰에서 subject(username)를 추출한다")
        fun `get username from token when token valid expect subject returned`() {
        }
    }
}
