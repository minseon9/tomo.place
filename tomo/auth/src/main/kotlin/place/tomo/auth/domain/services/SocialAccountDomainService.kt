package place.tomo.auth.domain.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.auth.domain.commands.LinkSocialAccountCommand
import place.tomo.auth.domain.entities.SocialAccountEntity
import place.tomo.auth.infra.repositories.SocialAccountRepository
import place.tomo.common.exception.HttpErrorStatus
import place.tomo.common.exception.HttpException
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
            throw HttpException(HttpErrorStatus.CONFLICT, "해당 ${command.provider} 계정은 이미 다른 회원과 연결되어 있습니다.")
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
                ?: throw HttpException(HttpErrorStatus.NOT_FOUND, "연결된 ${provider.name} 계정을 찾을 수 없습니다.")

        socialAccount.deactivate()
        socialAccountRepository.save(socialAccount)
    }
}
