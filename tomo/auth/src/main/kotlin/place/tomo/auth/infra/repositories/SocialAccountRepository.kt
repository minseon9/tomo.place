package place.tomo.infra.repositories

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import place.tomo.auth.domain.entities.SocialAccountEntity
import place.tomo.contract.constant.OIDCProviderType

interface SocialAccountRepository : JpaRepository<SocialAccountEntity, Long> {
    fun findByProviderAndSocialId(
        provider: OIDCProviderType,
        socialId: String,
    ): SocialAccountEntity?

    fun findByUserIdAndProviderAndIsActive(
        userId: Long,
        provider: OIDCProviderType,
        isActive: Boolean = true,
    ): SocialAccountEntity?

    fun existsByProviderAndSocialIdAndIsActive(
        provider: OIDCProviderType,
        socialId: String,
        isActive: Boolean = true,
    ): Boolean

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("update SocialAccountEntity s set s.isActive = false where s.userId = :userId and s.isActive = true")
    fun softDeleteByUserId(userId: Long): Int
}
