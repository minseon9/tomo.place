package place.tomo.auth.domain.services

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import place.tomo.auth.domain.commands.LinkSocialAccountCommand
import place.tomo.auth.domain.entities.SocialAccountEntity
import place.tomo.auth.domain.exception.SocialAccountConflictException
import place.tomo.auth.domain.exception.SocialAccountNotFoundException
import place.tomo.auth.infra.repositories.SocialAccountRepository
import place.tomo.contract.constant.OIDCProviderType
import place.tomo.contract.dtos.UserInfoDTO

@DisplayName("SocialAccountDomainService")
class SocialAccountDomainServiceTest {
    private lateinit var repository: SocialAccountRepository
    private lateinit var service: SocialAccountDomainService
    private val faker = Faker()

    @BeforeEach
    fun setUp() {
        repository = mockk(relaxed = true)
        service = SocialAccountDomainService(repository)
    }

    @Nested
    @DisplayName("소셜 계정 연결")
    inner class LinkSocialAccount {
        @Test
        @DisplayName("기존 연결이 없는 소셜 계정이면 새로운 소셜 계정 엔티티를 생성한다")
        fun `link social account when not exists expect created`() {
            val cmd = createLinkSocialAccountCommand(faker.internet().emailAddress())
            every { repository.findByProviderAndSocialId(cmd.provider, cmd.socialId) } returns null
            every { repository.save(any<SocialAccountEntity>()) } answers { firstArg() }

            val saved = service.linkSocialAccount(cmd)

            assertThat(saved.userId).isEqualTo(cmd.user.id)
            assertThat(saved.provider).isEqualTo(cmd.provider)
            assertThat(saved.socialId).isEqualTo(cmd.socialId)
            verify { repository.save(any<SocialAccountEntity>()) }
        }

        @Test
        @DisplayName("기존 연결이 다른 이메일과 연결되어 있으면 충돌 예외를 던진다")
        fun `link social account when linked to another email expect 409 conflict`() {
            val cmd = createLinkSocialAccountCommand(faker.internet().emailAddress())

            val existing =
                SocialAccountEntity.create(
                    cmd.user.id + 1,
                    cmd.provider,
                    cmd.socialId,
                    faker.internet().emailAddress(),
                    faker.name().username(),
                    null,
                )
            every { repository.findByProviderAndSocialId(cmd.provider, cmd.socialId) } returns existing

            assertThatThrownBy { service.linkSocialAccount(cmd) }
                .isInstanceOf(SocialAccountConflictException::class.java)
                .extracting("status")
                .isEqualTo(HttpStatus.CONFLICT)
        }

        @Test
        @DisplayName("기존 소셜 계정이 비활성 상태이면 활성화한다")
        fun `link social account when existing inactive expect activated`() {
            val cmd = createLinkSocialAccountCommand(faker.internet().emailAddress())
            val existing =
                SocialAccountEntity
                    .create(
                        cmd.user.id,
                        cmd.provider,
                        cmd.socialId,
                        cmd.email,
                        cmd.name,
                        cmd.profileImageUrl,
                    ).apply { deactivate() }
            every { repository.findByProviderAndSocialId(cmd.provider, cmd.socialId) } returns existing
            every { repository.save(existing) } returns existing

            val result = service.linkSocialAccount(cmd)

            assertThat(result.isActive).isTrue()
            verify { repository.save(existing) }
        }

        @Test
        @DisplayName("기존 소셜 계정이 활성 상태이면 그대로 반환한다")
        fun `link social account when existing active expect returned as is`() {
            val cmd = createLinkSocialAccountCommand(faker.internet().emailAddress())
            val existing =
                SocialAccountEntity
                    .create(
                        cmd.user.id,
                        cmd.provider,
                        cmd.socialId,
                        cmd.email,
                        cmd.name,
                        cmd.profileImageUrl,
                    )
            every { repository.findByProviderAndSocialId(cmd.provider, cmd.socialId) } returns existing

            val result = service.linkSocialAccount(cmd)

            assertThat(result).isSameAs(existing)
        }
    }

    @Nested
    @DisplayName("소셜 계정 활성 상태 확인")
    inner class CheckSocialAccount {
        @Test
        @DisplayName("provider/socialId로 활성 상태인 소셜 계정 존재 여부를 반환한다")
        fun `check social account when provider and social id given expect active status returned`() {
            val provider = OIDCProviderType.GOOGLE
            val socialId = faker.internet().uuid()
            every { repository.existsByProviderAndSocialIdAndIsActive(provider, socialId, true) } returns true

            val exists = service.checkSocialAccount(provider, socialId)

            assertThat(exists).isTrue()
        }
    }

    @Nested
    @DisplayName("소셜 계정 연결 해제")
    inner class UnlinkSocialAccount {
        @Test
        @DisplayName("존재하지 않는 소셜 계정 연결 해제 시 NOT_FOUND 예외를 던진다")
        fun `unlink social account when not found expect 404 not found`() {
            val userId = faker.random().nextLong()
            val provider = OIDCProviderType.GOOGLE
            every { repository.findByUserIdAndProviderAndIsActive(userId, provider, true) } returns null

            assertThatThrownBy { service.unlinkSocialAccount(userId, provider) }
                .isInstanceOf(SocialAccountNotFoundException::class.java)
                .extracting("status")
                .isEqualTo(HttpStatus.NOT_FOUND)
        }

        @Test
        @DisplayName("존재하는 소셜 계정 연결 해제 시 비활성화하고 저장한다")
        fun `unlink social account when exists expect deactivated and saved`() {
            val userId = faker.random().nextLong()
            val provider = OIDCProviderType.GOOGLE
            val entity =
                SocialAccountEntity.create(
                    userId,
                    provider,
                    faker.internet().uuid(),
                    faker.internet().emailAddress(),
                    faker.name().username(),
                    null,
                )
            every { repository.findByUserIdAndProviderAndIsActive(userId, provider, true) } returns entity
            every { repository.save(entity) } returns entity

            service.unlinkSocialAccount(userId, provider)

            assertThat(entity.isActive).isFalse()
            verify { repository.save(entity) }
        }
    }

    private fun createLinkSocialAccountCommand(email: String): LinkSocialAccountCommand {
        val userInfo = UserInfoDTO(1, email, faker.name().username())

        return LinkSocialAccountCommand(
            userInfo,
            OIDCProviderType.GOOGLE,
            "sid",
            email,
            userInfo.name,
            null,
        )
    }
}
