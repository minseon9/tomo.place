package place.tomo.infra.adapters

import org.springframework.stereotype.Component
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserQueryPort
import place.tomo.user.domain.services.UserDomainService
import place.tomo.user.infra.repositories.UserRepository

@Component
class UserQueryAdapter(
    private val userRepository: UserRepository,
    private val userDomainService: UserDomainService,
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

    override fun createUser(
        email: String,
        password: String,
        name: String,
    ) {
        userDomainService.createUser(email, password, name)
    }
}
