package dev.ian.mapa.infra.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.http.HttpStatus
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.provisioning.InMemoryUserDetailsManager
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.HttpStatusEntryPoint

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    // TODO: 특정 API endpoint는 인증 필요없도록 해야함. 회원가입, 로그인 같은 endpoint
    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder()

    @Bean
    fun userDetailsService(): UserDetailsService {
        val user =
            User
                .builder()
                .username("root")
                .password("{noop}rootpw")
                .roles("USER")
                .build()

        return InMemoryUserDetailsManager(user)
    }

    // FIXME: MVC에서는 다르게 동작해야하나 ?
    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain =
        http
            .csrf { csrf ->
                csrf.ignoringRequestMatchers("/api/members/signup")
            }.authorizeHttpRequests { auth ->
                auth
                    .requestMatchers(HttpMethod.POST, "/api/members/signup")
                    .permitAll()
                    .anyRequest()
                    .authenticated()
            }.exceptionHandling { exception ->
                exception.authenticationEntryPoint(HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED))
            }.formLogin { form ->
                form.loginPage("/login").permitAll()
            }.logout { logout ->
                logout.permitAll()
            }.httpBasic { }
            .build()
}
