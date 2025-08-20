package place.tomo.auth.domain.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.auth.domain.commands.LinkSocialAccountCommand
import place.tomo.auth.domain.entities.SocialAccountEntity
import place.tomo.auth.domain.exception.SocialAccountConflictException
import place.tomo.auth.domain.exception.SocialAccountNotFoundException
import place.tomo.auth.infra.repositories.SocialAccountRepository
import place.tomo.contract.constant.OIDCProviderType

@Service
class SocialAccountDomainService(
    private val socialAccountRepository: SocialAccountRepository,
) {
    @Transactional
    fun linkSocialAccount(command: LinkSocialAccountCommand): SocialAccountEntity {
        val existingSocialAccount =
            socialAccountRepository.findByProviderAndSocialId(command.provider, command.socialId)
                ?: return socialAccountRepository.save(
                    SocialAccountEntity.create(
                        userId = command.user.id,
                        provider = command.provider,
                        socialId = command.socialId,
                        email = command.email,
                        name = command.name,
                        profileImageUrl = command.profileImageUrl,
                    ),
                )

        if (existingSocialAccount.email != command.user.email) {
            throw SocialAccountConflictException(command.provider.name)
        }

        if (!existingSocialAccount.isActive) {
            existingSocialAccount.activate()
            socialAccountRepository.save(existingSocialAccount)
        }

        return existingSocialAccount
    }

    fun checkSocialAccount(
        provider: OIDCProviderType,
        socialId: String,
    ): Boolean = socialAccountRepository.existsByProviderAndSocialIdAndIsActive(provider, socialId)

    @Transactional
    fun unlinkSocialAccount(
        userId: Long,
        provider: OIDCProviderType,
    ) {
        val socialAccount =
            socialAccountRepository.findByUserIdAndProviderAndIsActive(userId, provider)
                ?: throw SocialAccountNotFoundException(provider.name)

        socialAccount.deactivate()
        socialAccountRepository.save(socialAccount)
    }
}
