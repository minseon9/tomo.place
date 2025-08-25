package place.tomo.common.test.security

import org.springframework.context.annotation.Profile
import org.springframework.stereotype.Component

@Component
@Profile("test")
class TestSecurityHelper(
    private val testUserProvider: TestUserProvider, // 의존성 주입으로 변경
) {
    fun withTestUser(
        email: String = "test@example.com",
        roles: List<String> = listOf("USER"),
        token: String = "test-token",
    ): TestUserSetup {
        testUserProvider.setUserInfo(token, email, roles)

        return TestUserSetup(token)
    }

    fun clearTestUsers() {
        testUserProvider.clear()
    }
}

class TestUserSetup(
    private val token: String,
) {
    fun getAuthHeader(): String = "Bearer $token"

    fun getToken(): String = token
}

// 테스트용 사용자 정보 제공자 - 싱글톤 컴포넌트로 변경
@Component
@Profile("test")
class TestUserProvider {
    private val userMap = mutableMapOf<String, TestUserInfo>()

    fun setUserInfo(
        token: String,
        email: String,
        roles: List<String> = listOf("USER"),
    ) {
        userMap[token] = TestUserInfo(email, roles)
    }

    fun getUserInfo(token: String): TestUserInfo = userMap[token] ?: TestUserInfo("test@example.com", listOf("USER"))

    fun clear() {
        userMap.clear()
    }
}

data class TestUserInfo(
    val email: String,
    val roles: List<String>,
)
