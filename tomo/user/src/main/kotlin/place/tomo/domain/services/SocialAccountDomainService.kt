package place.tomo.domain.services

import place.tomo.domain.entities.SocialAccountEntity
import place.tomo.domain.constant.OAuthProvider
import place.tomo.infra.repositories.SocialAccountRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.domain.commands.LinkSocialAccountCommand

@Service
class SocialAccountDomainService(
    private val socialAccountRepository: SocialAccountRepository,
    private val userDomainService: UserDomainService,
) {
    // FIXME: 이미 연결된 경우, 오류 처리가 아니라 entity를 반환
    @Transactional
    fun linkSocialAccount(
        command: LinkSocialAccountCommand,
    ): SocialAccountEntity {
        // 기존에 연결된 소셜 계정이 있는지 확인
        // FIXME: email로 조회. email이 nullable인 지 검증
        val existingSocialAccount = socialAccountRepository.findByProviderAndSocialIdAndIsActive(command.provider,command.socialId)
        // 해당 소셜 계정이 다른 회원에게 연결되어 있는지 확인
        if (socialAccountRepository.existsByProviderAndSocialId(provider, socialId)) {
            throw IllegalStateException("해당 ${provider.name} 계정은 이미 다른 회원과 연결되어 있습니다.")
        }

        if (existingSocialAccount != null) {
            return existingSocialAccount
        }
        // FIXME: password 빈 값 처리 필요
        val user = userDomainService.createUser()
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
}
