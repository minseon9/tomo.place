package place.tomo.infra.adapters

import org.springframework.stereotype.Component
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserQueryPort
import place.tomo.infra.repositories.UserRepository

@Component
class UserQueryAdapter(
    private val userRepository: UserRepository,
) : UserQueryPort {
    override fun findByEmail(email: String): UserInfoDTO? {
        val user = userRepository.findByEmail(email) ?: return null

        return UserInfoDTO(
            id = user.id,
            email = user.email,
            password = user.password,
            name = user.username,
        )
    }
}
