package place.tomo.auth.application.services

import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.stereotype.Service
import place.tomo.common.exception.HttpErrorStatus
import place.tomo.common.exception.HttpException
import place.tomo.contract.ports.UserDomainPort

@Service
class CustomUserDetailsService(
    private val userDomainPort: UserDomainPort,
) : UserDetailsService {
    override fun loadUserByUsername(username: String): UserDetails {
        val user =
            userDomainPort.findByEmail(username)
                ?: throw HttpException(HttpErrorStatus.UNAUTHORIZED, "회원을 찾을 수 없습니다: $username")

        return User
            .builder()
            .username(user.email)
            .password(user.password)
            .roles("USER")
            .build()
    }
}
