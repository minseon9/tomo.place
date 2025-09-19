package place.tomo.user.infra.adapters

import org.springframework.stereotype.Component
import place.tomo.common.exception.NotFoundActiveUserException
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserDomainPort
import place.tomo.user.domain.services.UserDomainService
import place.tomo.user.infra.repositories.UserRepository
import java.util.UUID

@Component
class UserDomainAdapter(
    private val userRepository: UserRepository,
    private val userDomainService: UserDomainService,
) : UserDomainPort {
    override fun findActiveByEntityId(entityId: String): UserInfoDTO? {
        val user = userRepository.findByEntityIdAndDeletedAtIsNull(UUID.fromString(entityId)) ?: return null
        if (!user.isActivated()) {
            throw NotFoundActiveUserException(user.email)
        }

        return UserInfoDTO(
            id = user.id,
            entityId = user.entityId,
            email = user.email,
            name = user.username,
        )
    }

    override fun getOrCreateActiveUser(
        email: String,
        name: String?,
    ): UserInfoDTO {
        val user = userDomainService.getOrCreateActiveUser(email, name ?: "")

        return UserInfoDTO(
            id = user.id,
            entityId = user.entityId,
            email = user.email,
            name = user.username,
        )
    }

    override fun softDelete(userId: Long) {
        // 통합 포트 요구 사항상 구현 필요. 별도 커맨드 어댑터에서 처리하던 softDelete를 간단 구현.
        val user = userRepository.findById(userId).orElse(null) ?: return

        user.deactivate()
        userRepository.save(user)
    }
}
