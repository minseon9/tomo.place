package place.tomo.user.domain.services

import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import place.tomo.common.exception.HttpErrorStatus
import place.tomo.common.exception.HttpException
import place.tomo.common.validation.password.PasswordValidator
import place.tomo.user.domain.entities.HashedPassword
import place.tomo.user.domain.entities.UserEntity
import place.tomo.user.infra.repositories.UserRepository

@Service
class UserDomainService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
    private val passwordValidator: PasswordValidator,
) {
    fun createUser(
        email: String,
        rawPassword: String,
        name: String,
    ): UserEntity {
        if (userRepository.findByEmail(email) != null) {
            throw HttpException(HttpErrorStatus.CONFLICT, "이미 존재하는 이메일입니다.")
        }

        val validation = passwordValidator.validate(rawPassword)
        if (!validation.isValid) {
            throw HttpException(
                HttpErrorStatus.BAD_REQUEST,
                "비밀번호는 8자 이상이며 대문자, 소문자, 숫자, 특수문자를 포함해야 합니다.",
            )
        }

        val userEntity = UserEntity.create(email, HashedPassword(passwordEncoder.encode(rawPassword)), name)
        userRepository.save(userEntity)

        return userEntity
    }
}
