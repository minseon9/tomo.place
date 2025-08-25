package place.tomo.user.domain.services

import org.springframework.stereotype.Service
import place.tomo.common.security.PasswordService
import place.tomo.user.domain.entities.HashedPassword
import place.tomo.user.domain.entities.UserEntity
import place.tomo.user.domain.exception.DuplicateEmailException
import place.tomo.user.domain.exception.InvalidPasswordException
import place.tomo.user.infra.repositories.UserRepository

@Service
class UserDomainService(
    private val userRepository: UserRepository,
    private val passwordDomain: PasswordService,
) {
    fun createUser(
        email: String,
        rawPassword: String,
        name: String,
    ): UserEntity {
        if (userRepository.findByEmail(email) != null) {
            throw DuplicateEmailException(email)
        }

        val validation = passwordDomain.validate(rawPassword)
        if (!validation.isValid) {
            throw InvalidPasswordException("비밀번호는 8자 이상이며 대문자, 소문자, 숫자, 특수문자를 포함해야 합니다.")
        }

        val userEntity = UserEntity.create(email, HashedPassword(passwordDomain.encode(rawPassword)), name)
        userRepository.save(userEntity)

        return userEntity
    }
}
