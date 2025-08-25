package place.tomo.common.resolvers.usercontext

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@DisplayName("UserContext")
class UserContextTest {
    @Nested
    @DisplayName("UserContext 생성")
    inner class UserContextCreation {
        @Test
        @DisplayName("기본 생성자로 UserContext를 생성할 때 모든 속성이 올바르게 설정된다")
        fun `create user context when basic constructor expect all properties set correctly`() {
            val userId = 123L
            val email = "user@example.com"
            val name = "Test User"

            val userContext = UserContext(userId, email, name)

            assertThat(userContext.userId).isEqualTo(userId)
            assertThat(userContext.email).isEqualTo(email)
            assertThat(userContext.name).isEqualTo(name)
        }

        @Test
        @DisplayName("companion object의 from 메서드로 UserContext를 생성할 때 올바른 객체가 반환된다")
        fun `create user context when from method expect correct object returned`() {
            val userId = 456L
            val email = "test@example.com"
            val name = "Another User"

            val userContext = UserContext.from(userId, email, name)

            assertThat(userContext).isInstanceOf(UserContext::class.java)
            assertThat(userContext.userId).isEqualTo(userId)
            assertThat(userContext.email).isEqualTo(email)
            assertThat(userContext.name).isEqualTo(name)
        }

        @Test
        @DisplayName("from 메서드와 기본 생성자가 동일한 결과를 반환한다")
        fun `from method and constructor when same parameters expect identical results`() {
            val userId = 789L
            val email = "same@example.com"
            val name = "Same User"

            val fromMethod = UserContext.from(userId, email, name)
            val constructor = UserContext(userId, email, name)

            assertThat(fromMethod).isEqualTo(constructor)
            assertThat(fromMethod.userId).isEqualTo(constructor.userId)
            assertThat(fromMethod.email).isEqualTo(constructor.email)
            assertThat(fromMethod.name).isEqualTo(constructor.name)
        }
    }

    @Nested
    @DisplayName("UserContext data class 기능")
    inner class UserContextDataClassFeatures {
        @Test
        @DisplayName("UserContext의 copy 메서드가 올바르게 동작한다")
        fun `user context copy method when invoked expect correct copy created`() {
            val original = UserContext(1L, "original@example.com", "Original User")

            val copied =
                original.copy(
                    userId = 2L,
                    email = "copied@example.com",
                )

            assertThat(copied.userId).isEqualTo(2L)
            assertThat(copied.email).isEqualTo("copied@example.com")
            assertThat(copied.name).isEqualTo("Original User")
            assertThat(copied).isNotEqualTo(original)
        }

        @Test
        @DisplayName("UserContext의 equals 메서드가 올바르게 동작한다")
        fun `user context equals method when same values expect true returned`() {
            val context1 = UserContext(1L, "test@example.com", "Test User")
            val context2 = UserContext(1L, "test@example.com", "Test User")
            val context3 = UserContext(2L, "test@example.com", "Test User")

            assertThat(context1).isEqualTo(context2)
            assertThat(context1).isNotEqualTo(context3)
        }

        @Test
        @DisplayName("UserContext의 toString 메서드가 모든 속성을 포함한다")
        fun `user context toString method when invoked expect all properties included`() {
            val userContext = UserContext(123L, "user@example.com", "Test User")

            val result = userContext.toString()

            assertThat(result).contains("123")
            assertThat(result).contains("user@example.com")
            assertThat(result).contains("Test User")
        }
    }
}
