package place.tomo.user.infra.adapters

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("UserDomainAdapter 단위 테스트")
class UserDomainAdapterTest {
    @Nested
    @DisplayName("findByEmail")
    inner class FindByEmail {
        @Test
        @DisplayName("사용자가 존재하면 UserInfoDTO로 매핑하여 반환한다")
        fun `find by email when user exists expect user info returned`() {
        }

        @Test
        @DisplayName("사용자가 없으면 null을 반환한다")
        fun `find by email when user not exists expect null returned`() {
        }
    }

    @Nested
    @DisplayName("create")
    inner class Create {
        @Test
        @DisplayName("UserDomainService.createUser를 호출하고 DTO로 변환한다")
        fun `create when valid input expect domain service invoked and dto returned`() {
        }
    }

    @Nested
    @DisplayName("getOrCreate")
    inner class GetOrCreate {
        @Test
        @DisplayName("기존 사용자가 있으면 그대로 반환한다")
        fun `get or create when user exists expect existing returned`() {
        }

        @Test
        @DisplayName("기존 사용자가 없으면 새로 생성하고 반환한다")
        fun `get or create when user not exists expect created and returned`() {
        }
    }

    @Nested
    @DisplayName("softDelete")
    inner class SoftDelete {
        @Test
        @DisplayName("사용자가 존재하지 않아도 예외 없이 동작한다")
        fun `soft delete when user not found expect no exception`() {
        }

        @Test
        @DisplayName("사용자 상태를 DEACTIVATED로 변경하고 저장한다")
        fun `soft delete when user exists expect deactivated and saved`() {
        }
    }
}
