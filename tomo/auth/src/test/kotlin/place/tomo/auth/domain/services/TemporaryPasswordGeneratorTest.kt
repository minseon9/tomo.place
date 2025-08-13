package place.tomo.auth.domain.services

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("TemporaryPasswordGenerator 단위 테스트")
class TemporaryPasswordGeneratorTest {
    @Nested
    @DisplayName("generate")
    inner class Generate {
        @Test
        @DisplayName("LengthPolicy의 최대 길이로 생성된다")
        fun `generate temporary password when invoked expect length equals max`() {
        }

        @Test
        @DisplayName("모든 비밀번호 정책(대/소문자, 숫자, 특수문자)을 만족한다")
        fun `generate temporary password when invoked expect satisfy all policies`() {
        }

        @Test
        @DisplayName("정책에 부합하지 않는 비밀번호가 생성되면 BAD_REQUEST 예외를 던진다")
        fun `generate temporary password when generated invalid expect 400 bad request`() {
        }
    }
}
