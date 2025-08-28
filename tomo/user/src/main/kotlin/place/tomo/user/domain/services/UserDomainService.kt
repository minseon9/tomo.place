package place.tomo.user.domain.services

import org.springframework.stereotype.Service
import place.tomo.user.domain.entities.UserEntity
import place.tomo.user.domain.exception.DuplicateEmailException
import place.tomo.user.infra.repositories.UserRepository

@Service
class UserDomainService(
    private val userRepository: UserRepository,
) {
    fun createUser(
        email: String,
        name: String,
    ): UserEntity {
        if (userRepository.findByEmail(email) != null) {
            throw DuplicateEmailException(email)
        }

        val userEntity = UserEntity.create(email, name)
        userRepository.save(userEntity)

        return userEntity
    }
}
