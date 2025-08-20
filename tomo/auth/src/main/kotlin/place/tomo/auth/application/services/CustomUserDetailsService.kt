package place.tomo.auth.application.services

import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.stereotype.Service
import place.tomo.auth.domain.exception.UserNotFoundByEmailException
import place.tomo.contract.ports.UserDomainPort

@Service
class CustomUserDetailsService(
    private val userDomainPort: UserDomainPort,
) : UserDetailsService {
    override fun loadUserByUsername(username: String): UserDetails {
        val user =
            userDomainPort.findActiveByEmail(username)
                ?: throw UserNotFoundByEmailException(username)

        return User
            .builder()
            .username(user.email)
            .password(user.password)
            .roles("USER")
            .build()
    }
}
