package place.tomo.user.domain.services

import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import place.tomo.user.domain.entities.UserEntity
import place.tomo.user.infra.repositories.UserRepository
import place.tomo.common.exception.HttpErrorStatus
import place.tomo.common.exception.HttpException

@Service
class UserDomainService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
) {
    // FIXME: OAuth 회원가입인 경우, user의 password가 비어있어야함. 해당 검증 필요
    fun createUser(
        email: String,
        rawPassword: String,
        name: String,
    ): UserEntity {
        if (userRepository.findByEmail(email) != null) {
            throw HttpException(HttpErrorStatus.CONFLICT, "이미 존재하는 이메일입니다.")
        }

        val encodedPassword = passwordEncoder.encode(rawPassword)

        val userEntity = UserEntity.create(email, encodedPassword, name)
        userRepository.save(userEntity)

        return userEntity
    }
}
