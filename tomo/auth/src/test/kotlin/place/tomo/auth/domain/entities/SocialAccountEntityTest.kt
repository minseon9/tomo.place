package place.tomo.auth.domain.entities

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("SocialAccountEntity 단위 테스트")
class SocialAccountEntityTest {
    @Nested
    @DisplayName("create")
    inner class Create {
        @Test
        @DisplayName("필수 필드로 엔티티를 생성한다")
        fun `create social account entity when valid fields provided expect entity created`() {
        }
    }

    @Nested
    @DisplayName("activate / deactivate")
    inner class ActivateDeactivate {
        @Test
        @DisplayName("deactivate 호출 시 isActive=false로 설정된다")
        fun `deactivate social account entity when called expect isActive false`() {
        }

        @Test
        @DisplayName("activate 호출 시 isActive=true로 설정된다")
        fun `activate social account entity when called expect isActive true`() {
        }
    }
}
