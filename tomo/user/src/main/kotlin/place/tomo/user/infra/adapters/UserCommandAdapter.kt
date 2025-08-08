package place.tomo.user.infra.adapters

import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import place.tomo.contract.ports.UserCommandPort
import place.tomo.contract.vo.UserId
import place.tomo.user.domain.entities.UserEntity
import place.tomo.user.infra.repositories.UserRepository

@Component
class UserCommandAdapter(
    private val userRepository: UserRepository,
) : UserCommandPort {
    @Transactional
    override fun create(email: String, rawPassword: String?, name: String?): UserId {
        val entity = UserEntity(email = email, password = rawPassword ?: "", username = name ?: "")
        val saved = userRepository.save(entity)
        return UserId(saved.id)
    }

    @Transactional
    override fun softDelete(userId: UserId) {
        val user = userRepository.findById(userId.value).orElse(null) ?: return
        user.status = place.tomo.user.domain.constant.UserStatus.INACTIVE
        userRepository.save(user)
    }
}


