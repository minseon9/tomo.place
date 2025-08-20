package place.tomo.auth.infra.repositories

import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import place.tomo.auth.domain.entities.SocialAccountEntity
import place.tomo.contract.constant.OIDCProviderType
import java.util.Locale

@DataJpaTest
@ContextConfiguration(classes = [AuthRepositoryTestConfig::class])
@ActiveProfiles("test")
@DisplayName("SocialAccountRepository")
class SocialAccountRepositoryTest {
    private val faker = Faker(Locale.KOREAN)

    @Autowired
    private lateinit var socialAccountRepository: SocialAccountRepository

    @BeforeEach
    fun setUp() {
        socialAccountRepository.deleteAll()
    }

    @Nested
    @DisplayName("findByProviderAndSocialId")
    inner class FindByProviderAndSocialId {
        @Test
        @DisplayName("Provider와 SocialId로 소셜 계정 조회 성공")
        fun `findByProviderAndSocialId when valid provider and socialId expect social account found`() {
            // Given
            val socialAccount =
                createSocialAccount(
                    provider = OIDCProviderType.GOOGLE,
                    userId = 1L,
                    isActive = true,
                )

            // When
            val found =
                socialAccountRepository.findByProviderAndSocialId(
                    OIDCProviderType.GOOGLE,
                    socialAccount.socialId,
                )

            // Then
            assertThat(found).isNotNull()
            assertThat(found?.provider).isEqualTo(OIDCProviderType.GOOGLE)
            assertThat(found?.socialId).isEqualTo(socialAccount.socialId)
        }

        @Test
        @DisplayName("존재하지 않는 Provider와 SocialId 조회 시 null 반환")
        fun `findByProviderAndSocialId when non existent expect null returned`() {
            // Given
            createSocialAccount(
                provider = OIDCProviderType.GOOGLE,
                userId = 1L,
                isActive = true,
            )

            // When
            val found =
                socialAccountRepository.findByProviderAndSocialId(
                    OIDCProviderType.GOOGLE,
                    "nonexistent",
                )

            // Then
            assertThat(found).isNull()
        }

        @Test
        @DisplayName("다른 Provider로 조회 시 null 반환")
        fun `findByProviderAndSocialId when different provider expect null returned`() {
            // Given
            createSocialAccount(
                provider = OIDCProviderType.GOOGLE,
                userId = 1L,
                isActive = true,
            )

            // When
            val found =
                socialAccountRepository.findByProviderAndSocialId(
                    OIDCProviderType.KAKAO,
                    "google123",
                )

            // Then
            assertThat(found).isNull()
        }
    }

    @Nested
    @DisplayName("findByUserIdAndProviderAndIsActive")
    inner class FindByUserIdAndProviderAndIsActive {
        @Test
        @DisplayName("UserId, Provider, IsActive로 소셜 계정 조회 성공")
        fun `findByUserIdAndProviderAndIsActive when valid params expect social account found`() {
            // Given
            createSocialAccount(
                provider = OIDCProviderType.GOOGLE,
                userId = 1L,
                isActive = true,
            )

            // When
            val found =
                socialAccountRepository.findByUserIdAndProviderAndIsActive(
                    userId = 1L,
                    provider = OIDCProviderType.GOOGLE,
                    isActive = true,
                )

            // Then
            assertThat(found).isNotNull()
            assertThat(found?.userId).isEqualTo(1L)
            assertThat(found?.provider).isEqualTo(OIDCProviderType.GOOGLE)
            assertThat(found?.isActive).isTrue()
        }

        @Test
        @DisplayName("비활성화된 계정은 조회되지 않음")
        fun `findByUserIdAndProviderAndIsActive when inactive account expect null returned`() {
            // Given
            createSocialAccount(
                provider = OIDCProviderType.GOOGLE,
                userId = 1L,
                isActive = false,
            )

            // When
            val found =
                socialAccountRepository.findByUserIdAndProviderAndIsActive(
                    userId = 1L,
                    provider = OIDCProviderType.GOOGLE,
                    isActive = true,
                )

            // Then
            assertThat(found).isNull()
        }

        @Test
        @DisplayName("IsActive가 false로 조회 시 비활성 계정 반환")
        fun `findByUserIdAndProviderAndIsActive when isActive false expect inactive account returned`() {
            // Given
            createSocialAccount(
                provider = OIDCProviderType.GOOGLE,
                userId = 1L,
                isActive = false,
            )

            // When
            val found =
                socialAccountRepository.findByUserIdAndProviderAndIsActive(
                    userId = 1L,
                    provider = OIDCProviderType.GOOGLE,
                    isActive = false,
                )

            // Then
            assertThat(found).isNotNull()
            assertThat(found?.isActive).isFalse()
        }
    }

    @Nested
    @DisplayName("existsByProviderAndSocialIdAndIsActive")
    inner class ExistsByProviderAndSocialIdAndIsActive {
        @Test
        @DisplayName("활성화된 소셜 계정이 존재할 때 true 반환")
        fun `existsByProviderAndSocialIdAndIsActive when active account exists expect true`() {
            // Given
            val socialAccount =
                createSocialAccount(
                    provider = OIDCProviderType.GOOGLE,
                    userId = 1L,
                    isActive = true,
                )

            // When
            val exists =
                socialAccountRepository.existsByProviderAndSocialIdAndIsActive(
                    provider = OIDCProviderType.GOOGLE,
                    socialId = socialAccount.socialId,
                    isActive = true,
                )

            // Then
            assertThat(exists).isTrue()
        }

        @Test
        @DisplayName("비활성화된 소셜 계정은 존재하지 않음으로 판단")
        fun `existsByProviderAndSocialIdAndIsActive when inactive account expect false`() {
            // Given
            val socialAccount =
                createSocialAccount(
                    provider = OIDCProviderType.GOOGLE,
                    userId = 1L,
                    isActive = false,
                )

            // When
            val exists =
                socialAccountRepository.existsByProviderAndSocialIdAndIsActive(
                    provider = OIDCProviderType.GOOGLE,
                    socialId = socialAccount.socialId,
                    isActive = true,
                )

            // Then
            assertThat(exists).isFalse()
        }

        @Test
        @DisplayName("존재하지 않는 소셜 계정은 false 반환")
        fun `existsByProviderAndSocialIdAndIsActive when non existent expect false`() {
            // Given & When
            val exists =
                socialAccountRepository.existsByProviderAndSocialIdAndIsActive(
                    provider = OIDCProviderType.GOOGLE,
                    socialId = faker.internet().uuid(),
                    isActive = true,
                )

            // Then
            assertThat(exists).isFalse()
        }
    }

    @Nested
    @DisplayName("softDeleteByUserId")
    inner class SoftDeleteByUserId {
        @Test
        @DisplayName("UserId로 활성화된 소셜 계정들을 비활성화")
        fun `softDeleteByUserId when active accounts exist expect accounts deactivated`() {
            // Create user 1 social accounts
            for (provider in OIDCProviderType.entries) {
                createSocialAccount(
                    provider = provider,
                    userId = 1L,
                    isActive = true,
                )
            }

            // Create another user social account
            createSocialAccount(
                provider = OIDCProviderType.GOOGLE,
                userId = 2L,
                isActive = true,
            )

            // When
            val updatedCount = socialAccountRepository.softDeleteByUserId(1L)

            // Then
            assertThat(updatedCount).isEqualTo(OIDCProviderType.entries.size)

            val remainingActive = socialAccountRepository.findAll().filter { it.isActive }
            assertThat(remainingActive).hasSize(1)
            assertThat(remainingActive[0].userId).isEqualTo(2L)
        }

        @Test
        @DisplayName("활성화된 계정이 없을 때 0 반환")
        fun `softDeleteByUserId when no active accounts expect 0 returned`() {
            // Given
            createSocialAccount(
                provider = OIDCProviderType.GOOGLE,
                userId = 1L,
                isActive = false,
            )

            // When
            val updatedCount = socialAccountRepository.softDeleteByUserId(1L)

            // Then
            assertThat(updatedCount).isEqualTo(0)
        }
    }

    private fun createSocialAccount(
        provider: OIDCProviderType,
        userId: Long,
        isActive: Boolean = true,
    ): SocialAccountEntity {
        val socialAccount =
            SocialAccountEntity(
                name = faker.name().fullName(),
                userId = userId,
                provider = provider,
                socialId = faker.internet().uuid(),
                email = faker.internet().emailAddress(),
                isActive = isActive,
                profileImageUrl = faker.internet().url(),
            )
        socialAccountRepository.save(socialAccount)

        return socialAccount
    }
}
