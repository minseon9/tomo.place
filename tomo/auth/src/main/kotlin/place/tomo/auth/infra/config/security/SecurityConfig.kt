package place.tomo.auth.infra.config.security

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.access.AccessDeniedHandler
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import place.tomo.auth.application.services.CustomUserDetailsService
import place.tomo.auth.domain.services.JwtTokenProvider
import place.tomo.contract.ports.UserDomainPort

@Configuration
@EnableWebSecurity
class SecurityConfig(
    private val jwtTokenProvider: JwtTokenProvider,
    private val userDomainPort: UserDomainPort,
) {
    private val publicPostEndpoints =
        arrayOf(
            "/api/auth/login",
            "/api/auth/signup",
            "/api/oidc/login",
            "/api/oidc/signup",
        )

    @Bean
    fun userDetailsService(): UserDetailsService = CustomUserDetailsService(userDomainPort)

    @Bean
    fun jwtAuthenticationFilter(userDetailsService: UserDetailsService): JwtAuthenticationFilter =
        JwtAuthenticationFilter(jwtTokenProvider, userDetailsService)

    @Bean
    fun authenticationManager(
        http: HttpSecurity,
        passwordEncoder: PasswordEncoder,
    ): AuthenticationManager {
        val builder = http.getSharedObject(AuthenticationManagerBuilder::class.java)
        builder
            .userDetailsService(userDetailsService())
            .passwordEncoder(passwordEncoder)
        return builder.build()
    }

    @Bean
    fun filterChain(
        http: HttpSecurity,
        jwtAuthenticationFilter: JwtAuthenticationFilter,
        authenticationEntryPoint: AuthenticationEntryPoint,
        accessDeniedHandler: AccessDeniedHandler,
    ): SecurityFilterChain =
        http
            .csrf { csrf ->
                csrf
                    .ignoringRequestMatchers(*publicPostEndpoints)
            }.authorizeHttpRequests { auth ->
                auth
                    .requestMatchers(HttpMethod.POST, *publicPostEndpoints)
                    .permitAll()
                    .anyRequest()
                    .authenticated()
            }.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter::class.java)
            .exceptionHandling { exception ->
                exception
                    .authenticationEntryPoint(authenticationEntryPoint)
                    .accessDeniedHandler(accessDeniedHandler)
            }.formLogin {
                it.disable()
            }.sessionManagement {
                it.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            }.logout { logout ->
                logout.permitAll()
            }.httpBasic { it.disable() }
            .build()

    @Bean
    fun authenticationEntryPoint(): AuthenticationEntryPoint = JsonAuthenticationEntryPoint()

    @Bean
    fun accessDeniedHandler(): AccessDeniedHandler = JsonAccessDeniedHandler()
}
