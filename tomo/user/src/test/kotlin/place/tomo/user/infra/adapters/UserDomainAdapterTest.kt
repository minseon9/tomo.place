package place.tomo.user.infra.adapters

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.vo.UserId
import place.tomo.user.domain.constant.UserStatus
import place.tomo.user.domain.entities.UserEntity
import place.tomo.user.domain.services.UserDomainService
import place.tomo.user.infra.repositories.UserRepository

@DisplayName("UserDomainAdapter")
class UserDomainAdapterTest {
    private lateinit var userRepository: UserRepository
    private lateinit var userDomainService: UserDomainService
    private lateinit var adapter: UserDomainAdapter
    private val faker = Faker()

    @BeforeEach
    fun setUp() {
        userRepository = mockk(relaxed = true)
        userDomainService = mockk()
        adapter = UserDomainAdapter(userRepository, userDomainService)
    }

    @Nested
    @DisplayName("이메일로 사용자 조회")
    inner class FindByEmail {
        @Test
        @DisplayName("존재하는 이메일로 사용자 조회 시 UserInfoDTO로 변환하여 반환한다")
        fun `find by email when user exists expect user info returned`() {
            val userId = faker.number().numberBetween(1L, 100L)
            val userEmail = faker.internet().emailAddress()
            val userName = faker.name().fullName()

            val entity = UserEntity(id = userId, email = userEmail, username = userName)
            every { userRepository.findByEmailAndDeletedAtIsNull(entity.email) } returns entity

            val dto = adapter.findActiveByEntityId(entity.email)

            assertThat(dto).isEqualTo(
                UserInfoDTO(
                    id = userId,
                    email = entity.email,
                    name = entity.username,
                ),
            )
        }

        @Test
        @DisplayName("존재하지 않는 이메일로 사용자 조회 시 null을 반환한다")
        fun `find by email when user not exists expect null returned`() {
            val nonExistentEmail = faker.internet().emailAddress()
            every { userRepository.findByEmailAndDeletedAtIsNull(nonExistentEmail) } returns null

            val dto = adapter.findActiveByEntityId(nonExistentEmail)

            assertThat(dto).isNull()
        }
    }

    @Nested
    @DisplayName("활성화된 사용자 조회 또는 생성")
    inner class GetOrCreateActiveUser {
        @Test
        @DisplayName("기존 활성화된 사용자가 존재하면 그대로 반환한다")
        fun `get or create active user when user exists expect existing returned`() {
            val userId = faker.number().numberBetween(1L, 100L)
            val userEmail = faker.internet().emailAddress()
            val userName = faker.name().fullName()

            val existing = UserEntity(id = userId, email = userEmail, username = userName)
            every { userDomainService.getOrCreateActiveUser(userEmail, userName) } returns existing

            val result = adapter.getOrCreateActiveUser(userEmail, userName)

            assertThat(result).isEqualTo(UserInfoDTO(id = userId, email = userEmail, name = userName))
            verify { userDomainService.getOrCreateActiveUser(userEmail, userName) }
        }

        @Test
        @DisplayName("기존 사용자가 없으면 새로 생성하고 UserInfoDTO로 반환한다")
        fun `get or create active user when user not exists expect created and returned`() {
            val userEmail = faker.internet().emailAddress()
            val userName = faker.name().fullName()
            val userId = faker.number().numberBetween(1L, 100L)

            val created = UserEntity(id = userId, email = userEmail, username = userName)
            every { userDomainService.getOrCreateActiveUser(userEmail, userName) } returns created

            val result = adapter.getOrCreateActiveUser(userEmail, userName)

            assertThat(result).isEqualTo(UserInfoDTO(id = userId, email = userEmail, name = userName))
            verify { userDomainService.getOrCreateActiveUser(userEmail, userName) }
        }
    }

    @Nested
    @DisplayName("사용자 소프트 삭제")
    inner class SoftDelete {
        @Test
        @DisplayName("존재하지 않는 사용자 소프트 삭제 시 예외 없이 동작한다")
        fun `soft delete when user not found expect no exception`() {
            val nonExistentUserId = faker.number().numberBetween(1000L, 9999L)
            every { userRepository.findById(nonExistentUserId) } returns java.util.Optional.empty()

            adapter.softDelete(UserId(nonExistentUserId))
        }

        @Test
        @DisplayName("존재하는 사용자 소프트 삭제 시 상태를 DEACTIVATED로 변경하고 저장한다")
        fun `soft delete when user exists expect deactivated and saved`() {
            val userId = faker.number().numberBetween(1L, 100L)
            val userEmail = faker.internet().emailAddress()
            val userName = faker.name().fullName()

            val entity = UserEntity(id = userId, email = userEmail, username = userName)
            every { userRepository.findById(userId) } returns java.util.Optional.of(entity)
            every { userRepository.save(any<UserEntity>()) } returnsArgument 0

            adapter.softDelete(UserId(userId))

            assertThat(entity.status).isEqualTo(UserStatus.DEACTIVATED)
            verify { userRepository.save(entity) }
        }
    }
}
