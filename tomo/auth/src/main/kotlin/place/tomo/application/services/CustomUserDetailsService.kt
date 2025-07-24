package place.tomo.application.services

import place.tomo.contract.ports.MemberQueryPort
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException

class CustomUserDetailsService(
    private val memberQueryPort: MemberQueryPort,
) : UserDetailsService {
    override fun loadUserByUsername(username: String): UserDetails {
        val memberInfo =
            memberQueryPort.findByEmail(username)
                ?: throw UsernameNotFoundException("회원을 찾을 수 없습니다: $username")

        return User
            .builder()
            .username(memberInfo.email)
            .password(memberInfo.password)
            .roles("USER")
            .build()
    }
}
