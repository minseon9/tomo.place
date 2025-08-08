package place.tomo.domain.services

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import place.tomo.auth.domain.commands.LinkSocialAccountCommand
import place.tomo.auth.domain.entities.SocialAccountEntity
import place.tomo.contract.constant.OIDCProviderType
import place.tomo.infra.repositories.SocialAccountRepository
import place.tomo.contract.ports.UserCommandPort

@Service
class SocialAccountDomainService(
    private val socialAccountRepository: SocialAccountRepository,
    private val userCommandPort: UserCommandPort,
) {
    @Transactional
    fun linkSocialAccount(command: LinkSocialAccountCommand): SocialAccountEntity {
        // 기존에 연결된 소셜 계정이 있는지 확인
        // FIXME: email로 조회. email이 nullable인 지 검증
        val existingSocialAccount = socialAccountRepository.findByProviderAndSocialIdAndIsActive(command.provider, command.socialId)
        // 해당 소셜 계정이 다른 회원에게 연결되어 있는지 확인
//        if (socialAccountRepository.existsByProviderAndSocialId(provider, socialId)) {
//            throw IllegalStateException("해당 ${provider.name} 계정은 이미 다른 회원과 연결되어 있습니다.")
//        }

        if (existingSocialAccount != null) {
            return existingSocialAccount
        }

        // FIXME: password 빈 값 처리 필요
        val userId = userCommandPort.create(command.email ?: "", "", command.name)
        val socialAccount =
            SocialAccountEntity.create(
                userId = userId.value,
                provider = command.provider,
                socialId = command.socialId,
                email = command.email,
                name = command.name,
                profileImageUrl = command.profileImageUrl,
            )

        return socialAccountRepository.save(socialAccount)
    }

    @Transactional
    fun unlinkSocialAccount(
        userId: Long,
        provider: OIDCProviderType,
    ) {
        val socialAccount =
            socialAccountRepository.findByUserIdAndProviderAndIsActive(userId, provider)
                ?: throw IllegalArgumentException("연결된 ${provider.name} 계정을 찾을 수 없습니다.")

        socialAccount.deactivate()
        socialAccountRepository.save(socialAccount)
    }
}
