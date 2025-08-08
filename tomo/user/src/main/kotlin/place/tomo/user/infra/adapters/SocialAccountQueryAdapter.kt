package place.tomo.user.infra.adapters

import org.springframework.stereotype.Component
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.SocialAccountQueryPort
import place.tomo.user.infra.repositories.UserRepository

@Component
class SocialAccountQueryAdapter(
    private val userRepository: UserRepository,
) : SocialAccountQueryPort {
    override fun findByEmail(email: String): UserInfoDTO? {
        val user = userRepository.findByEmail(email) ?: return null

        return UserInfoDTO(
            id = user.id,
            email = user.email,
            password = user.password,
            name = user.username,
        )
    }

    override fun linkSocialAccount(
        email: String,
        password: String,
        name: String,
    ) {
        // no-op: linking is handled in auth domain via command port
    }
}


