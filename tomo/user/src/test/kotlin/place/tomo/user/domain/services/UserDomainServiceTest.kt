package place.tomo.user.domain.services

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import place.tomo.user.domain.entities.UserEntity
import place.tomo.user.domain.exception.DuplicateEmailException
import place.tomo.user.infra.repositories.UserRepository

@DisplayName("UserDomainService")
class UserDomainServiceTest {
    private lateinit var userRepository: UserRepository
    private lateinit var service: UserDomainService

    @BeforeEach
    fun setUp() {
        userRepository = mockk(relaxed = true)
        service = UserDomainService(userRepository)
    }

    @Nested
    @DisplayName("사용자 생성")
    inner class CreateUser {
        @Test
        @DisplayName("중복되지 않는 이메일로 사용자 생성 성공 시 UserEntity를 반환한다")
        fun `create user when email unique expect entity created`() {
            // Arrange
            val email = "user@example.com"
            val name = "Tomo"

            every { userRepository.findByEmail(email) } returns null
            every { userRepository.save(any<UserEntity>()) } returnsArgument 0

            // Act
            val created = service.createUser(email, name)

            // Assert
            assertThat(created).isNotNull()
            assertThat(created.id).isEqualTo(0L) // service returns the same instance passed to save
            assertThat(created.email).isEqualTo(email)
            assertThat(created.username).isEqualTo(name)
            verify { userRepository.save(any<UserEntity>()) }
        }

        @Test
        @DisplayName("이미 존재하는 이메일로 사용자 생성 시 예외를 던진다")
        fun `create user when email duplicated expect exception`() {
            // Arrange
            val email = "dup@example.com"
            val existing = UserEntity(id = 1, email = email, username = "name")
            every { userRepository.findByEmail(email) } returns existing

            // Act & Assert
            assertThatThrownBy { service.createUser(email, "Name") }
                .isInstanceOf(DuplicateEmailException::class.java)
                .extracting("status")
                .isEqualTo(HttpStatus.CONFLICT)
        }
    }
}
