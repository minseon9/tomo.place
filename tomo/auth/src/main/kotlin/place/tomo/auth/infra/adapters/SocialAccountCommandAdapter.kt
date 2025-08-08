package place.tomo.infra.adapters

import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import place.tomo.auth.domain.entities.SocialAccountEntity
import place.tomo.infra.repositories.SocialAccountRepository
import place.tomo.contract.constant.OIDCProviderType
import place.tomo.contract.ports.SocialAccountCommandPort
import place.tomo.contract.vo.UserId

@Component
class SocialAccountCommandAdapter(
    private val socialAccountRepository: SocialAccountRepository,
) : SocialAccountCommandPort {
    @Transactional
    override fun link(
        userId: UserId,
        provider: OIDCProviderType,
        subject: String,
        email: String?,
        name: String?,
        profileImageUrl: String?,
    ) {
        val entity = SocialAccountEntity.create(userId = userId.value, provider = provider, socialId = subject, email = email, name = name, profileImageUrl = profileImageUrl)
        socialAccountRepository.save(entity)
    }

    @Transactional
    override fun softDeleteByUserId(userId: UserId) {
        socialAccountRepository.softDeleteByUserId(userId.value)
    }
}


