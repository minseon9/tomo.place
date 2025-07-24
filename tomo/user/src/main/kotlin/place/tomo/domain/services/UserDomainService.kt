package place.tomo.domain.services

import place.tomo.domain.entities.UserEntity
import place.tomo.infra.repositories.UserRepository
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service

@Service
class UserDomainService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
) {
    fun findByEmail(email: String): UserEntity? {
        return userRepository.findByEmail(email)
    }
    
    fun findById(id: Long): UserEntity? {
        return userRepository.findById(id).orElse(null)
    }

    fun createUser(
        email: String,
        rawPassword: String,
        name: String,
    ): UserEntity {
        if (userRepository.findByEmail(email) != null) {
            throw IllegalArgumentException("이미 존재하는 이메일입니다.")
        }

        val encodedPassword = passwordEncoder.encode(rawPassword)

        val userEntity = UserEntity.create(email, encodedPassword, name)
        userRepository.save(userEntity)

        return userEntity
    }
} 