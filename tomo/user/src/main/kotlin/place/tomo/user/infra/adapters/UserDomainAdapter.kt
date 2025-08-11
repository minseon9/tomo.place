package place.tomo.infra.adapters

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
    override fun findByEmail(email: String): UserInfoDTO? {
        val user = userRepository.findByEmail(email) ?: return null

        return UserInfoDTO(
            id = user.id,
            email = user.email,
            password = user.password,
            name = user.username,
        )
    }

    override fun create(
        email: String,
        rawPassword: String?,
        name: String?,
    ): UserInfoDTO {
        val created = userDomainService.createUser(email, rawPassword ?: "", name ?: "")
        return UserInfoDTO(
            id = created.id,
            email = created.email,
            password = created.password,
            name = created.username,
        )
    }

    override fun getOrCreate(
        email: String,
        rawPassword: String?,
        name: String?,
    ): UserInfoDTO {
        val existingUser = findByEmail(email)

        return existingUser ?: create(
            email = email,
            rawPassword = null,
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
