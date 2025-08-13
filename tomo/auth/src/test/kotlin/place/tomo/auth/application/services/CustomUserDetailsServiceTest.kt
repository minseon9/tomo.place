package place.tomo.auth.application.services

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("CustomUserDetailsService 단위 테스트")
class CustomUserDetailsServiceTest {
    @Nested
    @DisplayName("loadUserByUsername")
    inner class LoadUserByUsername {
        @Test
        @DisplayName("이메일로 사용자를 찾고 UserDetails로 매핑한다")
        fun `load user by username when email exists expect user details returned`() {
        }

        @Test
        @DisplayName("존재하지 않는 경우 UNAUTHORIZED 예외를 던진다")
        fun `load user by username when email not found expect throws unauthorized`() {
        }
    }
}
