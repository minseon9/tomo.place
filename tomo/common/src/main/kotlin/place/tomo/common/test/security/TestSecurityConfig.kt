package place.tomo.common.test.security

import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Primary
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.web.SecurityFilterChain

@TestConfiguration
class TestSecurityConfig {
    private val publicPostEndpoints =
        arrayOf(
            "/api/auth/signup",
        )

    @Bean
    @Primary
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain =
        http
            .csrf { csrf ->
                csrf.disable()
            }.authorizeHttpRequests { auth ->
                auth
                    .requestMatchers(HttpMethod.POST, *publicPostEndpoints)
                    .permitAll()
                    .anyRequest()
                    .authenticated()
            }.formLogin { it.disable() }
            .sessionManagement {
                it.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            }.logout { logout ->
                logout.permitAll()
            }.httpBasic { it.disable() }
            .build()
}
