package dev.ian.mapa.infra.repositories.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder

@Configuration
class SecurityConfig {
    // TODO: 특정 API endpoint는 인증 필요없도록 해야함. 회원가입, 로그인 같은 endpoint
    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder()
}
