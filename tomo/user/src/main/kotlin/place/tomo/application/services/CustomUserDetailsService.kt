package place.tomo.application.services

import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service
import place.tomo.infra.repositories.UserRepository

@Service
class CustomUserDetailsService(
    private val userRepository: UserRepository,
) : UserDetailsService {
    override fun loadUserByUsername(username: String): UserDetails {
        val user = userRepository.findByEmail(username)
            ?: throw UsernameNotFoundException("회원을 찾을 수 없습니다: $username")

        return User
            .builder()
            .username(user.email)
            .password(user.password)
            .roles("USER")
            .build()
    }
} 
