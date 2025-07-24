package place.tomo.infra.repositories

import place.tomo.domain.entities.SocialAccountEntity
import place.tomo.domain.constant.OAuthProvider
import org.springframework.data.jpa.repository.JpaRepository

interface SocialAccountRepository : JpaRepository<SocialAccountEntity, Long> {
    fun findByProviderAndSocialIdAndIsActive(
        provider: OAuthProvider, 
        socialId: String, 
        isActive: Boolean = true
    ): SocialAccountEntity?
    
    fun findByUserIdAndProviderAndIsActive(
        userId: Long, 
        provider: OAuthProvider, 
        isActive: Boolean = true
    ): SocialAccountEntity?
    
    fun findByUserIdAndIsActive(
        userId: Long, 
        isActive: Boolean = true
    ): List<SocialAccountEntity>
    
    fun existsByProviderAndSocialId(
        provider: OAuthProvider, 
        socialId: String
    ): Boolean
} 