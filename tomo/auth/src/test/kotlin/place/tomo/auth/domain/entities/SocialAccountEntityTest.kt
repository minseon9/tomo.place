package place.tomo.auth.domain.entities

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.contract.constant.OIDCProviderType

@DisplayName("SocialAccountEntity 단위 테스트")
class SocialAccountEntityTest {
    @Nested
    @DisplayName("create")
    inner class Create {
        @Test
        @DisplayName("필수 필드로 엔티티를 생성한다")
        fun `create social account entity when valid fields provided expect entity created`() {
            val entity = SocialAccountEntity.create(
                userId = 1L,
                provider = OIDCProviderType.GOOGLE,
                socialId = "sid",
                email = "user@example.com",
                name = "User",
                profileImageUrl = null,
            )

            assertThat(entity.userId).isEqualTo(1L)
            assertThat(entity.isActive).isTrue()
        }
    }

    @Nested
    @DisplayName("activate / deactivate")
    inner class ActivateDeactivate {
        @Test
        @DisplayName("deactivate 호출 시 isActive=false로 설정된다")
        fun `deactivate social account entity when called expect isActive false`() {
            val entity = SocialAccountEntity.create(1, OIDCProviderType.GOOGLE, "sid", "user@example.com", "User", null)
            entity.deactivate()
            assertThat(entity.isActive).isFalse()
        }

        @Test
        @DisplayName("activate 호출 시 isActive=true로 설정된다")
        fun `activate social account entity when called expect isActive true`() {
            val entity = SocialAccountEntity.create(1, OIDCProviderType.GOOGLE, "sid", "user@example.com", "User", null)
            entity.deactivate()
            entity.activate()
            assertThat(entity.isActive).isTrue()
        }
    }
}
