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
import place.tomo.user.domain.constant.UserStatus
import place.tomo.user.domain.entities.UserEntity
import place.tomo.user.domain.services.UserDomainService
import place.tomo.user.infra.repositories.UserRepository
import java.util.UUID

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
            val entity = createDummyUserEntity()
            every { userRepository.findByEntityIdAndDeletedAtIsNull(entity.entityId) } returns entity

            val dto = adapter.findActiveByEntityId(entity.entityId.toString())

            assertThat(dto).isEqualTo(
                UserInfoDTO(
                    id = entity.id,
                    entityId = entity.entityId,
                    email = entity.email,
                    name = entity.username,
                ),
            )
        }

        @Test
        @DisplayName("존재하지 않는 이메일로 사용자 조회 시 null을 반환한다")
        fun `find by email when user not exists expect null returned`() {
            val nonExistingEntityId = UUID.randomUUID()
            every { userRepository.findByEntityIdAndDeletedAtIsNull(nonExistingEntityId) } returns null

            val dto = adapter.findActiveByEntityId(nonExistingEntityId.toString())

            assertThat(dto).isNull()
        }
    }

    @Nested
    @DisplayName("활성화된 사용자 조회 또는 생성")
    inner class GetOrCreateActiveUser {
        @Test
        @DisplayName("기존 활성화된 사용자가 존재하면 그대로 반환한다")
        fun `get or create active user when user exists expect existing returned`() {
            val existing = createDummyUserEntity()
            every { userDomainService.getOrCreateActiveUser(existing.email, existing.username) } returns existing

            val result = adapter.getOrCreateActiveUser(existing.email, existing.username)

            assertThat(
                result,
            ).isEqualTo(UserInfoDTO(id = existing.id, entityId = existing.entityId, email = existing.email, name = existing.username))
            verify { userDomainService.getOrCreateActiveUser(existing.email, existing.username) }
        }

        @Test
        @DisplayName("기존 사용자가 없으면 새로 생성하고 UserInfoDTO로 반환한다")
        fun `get or create active user when user not exists expect created and returned`() {
            val created = createDummyUserEntity()
            every { userDomainService.getOrCreateActiveUser(created.email, created.username) } returns created

            val result = adapter.getOrCreateActiveUser(created.email, created.username)

            assertThat(
                result,
            ).isEqualTo(UserInfoDTO(id = created.id, entityId = created.entityId, email = created.email, name = created.username))
            verify { userDomainService.getOrCreateActiveUser(created.email, created.username) }
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

            adapter.softDelete(nonExistentUserId)
        }

        @Test
        @DisplayName("존재하는 사용자 소프트 삭제 시 상태를 DEACTIVATED로 변경하고 저장한다")
        fun `soft delete when user exists expect deactivated and saved`() {
            val entity = createDummyUserEntity()
            every { userRepository.findById(entity.id) } returns java.util.Optional.of(entity)
            every { userRepository.save(any<UserEntity>()) } returnsArgument 0

            adapter.softDelete(entity.id)

            assertThat(entity.status).isEqualTo(UserStatus.DEACTIVATED)
            verify { userRepository.save(entity) }
        }
    }

    private fun createDummyUserEntity(): UserEntity =
        UserEntity(
            id = faker.number().numberBetween(1L, 100L),
            entityId = UUID.randomUUID(),
            email = faker.internet().emailAddress(),
            username = faker.name().fullName(),
        )
}
