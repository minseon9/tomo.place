package place.tomo.user.infra.adapters

import org.springframework.stereotype.Component
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserDomainPort
import place.tomo.user.domain.services.UserDomainService
import place.tomo.user.infra.repositories.UserRepository

@Component
class UserDomainAdapter(
    private val userRepository: UserRepository,
    private val userDomainService: UserDomainService,
) : UserDomainPort {
    override fun findActiveByEmail(email: String): UserInfoDTO? {
        val user = userRepository.findByEmailAndDeletedAtIsNull(email) ?: return null
        require(user.isActivated())

        return UserInfoDTO(
            id = user.id,
            email = user.email,
            name = user.username,
            isActivated = user.isActivated(),
        )
    }

    override fun findByEmail(email: String): UserInfoDTO? {
        val user = userRepository.findByEmail(email) ?: return null
        return UserInfoDTO(
            id = user.id,
            email = user.email,
            name = user.username,
            isActivated = user.isActivated(),
        )
    }

    override fun create(
        email: String,
        name: String?,
    ): UserInfoDTO {
        val user = userDomainService.createUser(email, name ?: "")
        require(user.isActivated())

        return UserInfoDTO(
            id = user.id,
            email = user.email,
            name = user.username,
            isActivated = user.isActivated(),
        )
    }

    override fun getOrCreate(
        email: String,
        name: String?,
    ): UserInfoDTO {
        val existingUser = findActiveByEmail(email)

        return existingUser ?: create(
            email = email,
            name = name,
        )
    }

    override fun softDelete(userId: place.tomo.contract.vo.UserId) {
        // 통합 포트 요구 사항상 구현 필요. 별도 커맨드 어댑터에서 처리하던 softDelete를 간단 구현.
        val user = userRepository.findById(userId.value).orElse(null) ?: return
        user.status = place.tomo.user.domain.constant.UserStatus.DEACTIVATED
        userRepository.save(user)
    }
}
