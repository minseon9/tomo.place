package place.tomo.auth.domain.services

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("SocialAccountDomainService 단위 테스트")
class SocialAccountDomainServiceTest {
    @Nested
    @DisplayName("linkSocialAccount")
    inner class LinkSocialAccount {
        @Test
        @DisplayName("기존 연결 없으면 새로운 소셜 계정을 생성한다")
        fun `link social account when not exists expect created`() {
        }

        @Test
        @DisplayName("기존 연결이 다른 이메일과 연결되어 있으면 CONFLICT를 던진다")
        fun `link social account when linked to another email expect 409 conflict`() {
        }

        @Test
        @DisplayName("기존 계정이 비활성 상태면 활성화한다")
        fun `link social account when existing inactive expect activated`() {
        }

        @Test
        @DisplayName("기존 계정이 활성 상태면 그대로 반환한다")
        fun `link social account when existing active expect returned as is`() {
        }
    }

    @Nested
    @DisplayName("checkSocialAccount")
    inner class CheckSocialAccount {
        @Test
        @DisplayName("provider/socialId로 활성 상태 여부를 반환한다")
        fun `check social account when provider and social id given expect active status returned`() {
        }
    }

    @Nested
    @DisplayName("unlinkSocialAccount")
    inner class UnlinkSocialAccount {
        @Test
        @DisplayName("존재하지 않으면 NOT_FOUND를 던진다")
        fun `unlink social account when not found expect 404 not found`() {
        }

        @Test
        @DisplayName("존재하면 비활성화하고 저장한다")
        fun `unlink social account when exists expect deactivated and saved`() {
        }
    }
}
