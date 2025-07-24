package place.tomo.domain.services

import place.tomo.domain.entities.SocialAccountEntity
import place.tomo.domain.constant.OAuthProvider
import place.tomo.infra.repositories.SocialAccountRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class SocialAccountDomainService(
    private val socialAccountRepository: SocialAccountRepository
) {
    
    fun findBySocialAccount(provider: OAuthProvider, socialId: String): SocialAccountEntity? {
        return socialAccountRepository.findByProviderAndSocialIdAndIsActive(provider, socialId)
    }
    
    @Transactional
    fun linkSocialAccount(
        userId: Long,
        provider: OAuthProvider,
        socialId: String,
        email: String?,
        name: String?,
        profileImageUrl: String?
    ): SocialAccountEntity {
        // 기존에 연결된 소셜 계정이 있는지 확인
        val existingSocialAccount = socialAccountRepository.findByUserIdAndProviderAndIsActive(userId, provider)
        if (existingSocialAccount != null) {
            throw IllegalStateException("이미 ${provider.name} 계정이 연결되어 있습니다.")
        }
        
        // 해당 소셜 계정이 다른 회원에게 연결되어 있는지 확인
        if (socialAccountRepository.existsByProviderAndSocialId(provider, socialId)) {
            throw IllegalStateException("해당 ${provider.name} 계정은 이미 다른 회원과 연결되어 있습니다.")
        }
        
        val socialAccount = SocialAccountEntity.create(
            userId = userId,
            provider = provider,
            socialId = socialId,
            email = email,
            name = name,
            profileImageUrl = profileImageUrl
        )
        
        return socialAccountRepository.save(socialAccount)
    }
    
    @Transactional
    fun unlinkSocialAccount(userId: Long, provider: OAuthProvider) {
        val socialAccount = socialAccountRepository.findByUserIdAndProviderAndIsActive(userId, provider)
            ?: throw IllegalArgumentException("연결된 ${provider.name} 계정을 찾을 수 없습니다.")
        
        socialAccount.deactivate()
        socialAccountRepository.save(socialAccount)
    }
    
    fun getLinkedSocialAccounts(userId: Long): List<SocialAccountEntity> {
        return socialAccountRepository.findByUserIdAndIsActive(userId)
    }
} 