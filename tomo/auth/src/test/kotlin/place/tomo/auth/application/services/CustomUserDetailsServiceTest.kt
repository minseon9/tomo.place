package place.tomo.auth.application.services

import io.mockk.every
import io.mockk.mockk
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import org.springframework.security.core.userdetails.UserDetails
import place.tomo.auth.domain.exception.UserNotFoundByEmailException
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserDomainPort

@DisplayName("CustomUserDetailsService")
class CustomUserDetailsServiceTest {
    private val faker = Faker()
    private lateinit var userDomainPort: UserDomainPort
    private lateinit var service: CustomUserDetailsService

    @BeforeEach
    fun setUp() {
        userDomainPort = mockk()
        service = CustomUserDetailsService(userDomainPort)
    }

    @Nested
    @DisplayName("사용자 정보 조회")
    inner class LoadUserByUsername {
        @Test
        @DisplayName("존재하는 이메일로 사용자를 찾아 Spring Security UserDetails로 매핑하여 반환한다")
        fun `load user by username when email exists expect user details returned`() {
            val email = faker.internet().emailAddress()
            every { userDomainPort.findActiveByEmail(email) } returns
                UserInfoDTO(1, email, faker.name().fullName())

            val details: UserDetails = service.loadUserByUsername(email)

            assertThat(details.username).isEqualTo(email)
            assertThat(details.authorities).hasSize(1)
            assertThat(details.authorities.first().authority).isEqualTo("ROLE_USER")
        }

        @Test
        @DisplayName("존재하지 않는 이메일인 경우 UNAUTHORIZED 예외를 던진다")
        fun `load user by username when email not found expect throws unauthorized`() {
            every { userDomainPort.findActiveByEmail(any()) } returns null

            assertThatThrownBy { service.loadUserByUsername("none@example.com") }
                .isInstanceOf(UserNotFoundByEmailException::class.java)
                .extracting("status")
                .isEqualTo(HttpStatus.UNAUTHORIZED)
        }
    }
}
