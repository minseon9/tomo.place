package place.tomo.application.services

import place.tomo.domain.services.UserDomainService
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service

@Service
class CustomUserDetailsService(
    private val userDomainService: UserDomainService,
) : UserDetailsService {
    override fun loadUserByUsername(username: String): UserDetails {
        val user = userDomainService.findByEmail(username)
            ?: throw UsernameNotFoundException("회원을 찾을 수 없습니다: $username")

        return User
            .builder()
            .username(user.email)
            .password(user.password)
            .roles("USER")
            .build()
    }
} 