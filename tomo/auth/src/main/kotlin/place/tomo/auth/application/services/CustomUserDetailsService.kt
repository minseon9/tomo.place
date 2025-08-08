package place.tomo.auth.application.services

import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service
import place.tomo.contract.ports.UserQueryPort

@Service
class CustomUserDetailsService(
    private val userQueryPort: UserQueryPort,
) : UserDetailsService {
    override fun loadUserByUsername(username: String): UserDetails {
        val user =
            userQueryPort.findByEmail(username)
                ?: throw UsernameNotFoundException("회원을 찾을 수 없습니다: $username")

        return User
            .builder()
            .username(user.email)
            .password(user.password)
            .roles("USER")
            .build()
    }
}
