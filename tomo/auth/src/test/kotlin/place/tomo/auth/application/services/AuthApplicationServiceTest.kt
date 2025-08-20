package place.tomo.auth.application.services

import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import place.tomo.auth.application.requests.EmailPasswordAuthenticateRequest
import place.tomo.auth.application.responses.LoginResponse
import place.tomo.auth.domain.dtos.AuthTokenDTO
import place.tomo.auth.domain.exception.AuthenticationFailedException
import place.tomo.auth.domain.services.AuthenticationService
import place.tomo.contract.ports.UserDomainPort

@DisplayName("AuthApplicationService")
class AuthApplicationServiceTest {
    private lateinit var authenticationService: AuthenticationService
    private lateinit var userDomainPort: UserDomainPort
    private lateinit var service: AuthApplicationService

    @BeforeEach
    fun setUp() {
        authenticationService = mockk()
        userDomainPort = mockk()
        service = AuthApplicationService(authenticationService, userDomainPort)
    }

    @Nested
    @DisplayName("이메일/비밀번호 로그인")
    inner class AuthenticateEmailPassword {
        @Test
        @DisplayName("이메일/비밀번호 인증 성공 시 토큰 정보를 LoginResponse로 변환하여 반환한다")
        fun `authenticate when email and password valid expect login response returned`() {
            val req = EmailPasswordAuthenticateRequest(email = "user@example.com", password = "secret")
            every { authenticationService.authenticateEmailPassword(req.email, req.password) } returns AuthTokenDTO("access", "refresh")

            val res: LoginResponse = service.authenticate(req)

            assertThat(res.token).isEqualTo("access")
            assertThat(res.refreshToken).isEqualTo("refresh")
        }

        @Test
        @DisplayName("이메일 또는 비밀번호가 잘못된 경우 인증 실패 예외를 그대로 전달한다")
        fun `authenticate when email or password invalid expect throws unauthorized`() {
            val req = EmailPasswordAuthenticateRequest(email = "user@example.com", password = "bad")
            every { authenticationService.authenticateEmailPassword(req.email, req.password) } throws
                AuthenticationFailedException()

            assertThatThrownBy { service.authenticate(req) }
                .isInstanceOf(AuthenticationFailedException::class.java)
                .extracting("status")
                .isEqualTo(HttpStatus.UNAUTHORIZED)
        }
    }
}
