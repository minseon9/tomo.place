package place.tomo.infra.config.security

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.access.AccessDeniedHandler
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import place.tomo.auth.domain.services.JwtTokenProvider

@Configuration
class SecurityFilterChainConfig(
    private val jwtTokenProvider: JwtTokenProvider,
) {
    private val publicPostEndpoints =
        arrayOf(
            "/api/auth/login",
            "/api/auth/signup",
            "/api/oidc/login",
            "/api/oidc/signup",
        )

    @Bean
    fun authenticationManager(
        http: HttpSecurity,
        passwordEncoder: PasswordEncoder,
        userDetailsService: UserDetailsService,
    ): AuthenticationManager {
        val builder = http.getSharedObject(AuthenticationManagerBuilder::class.java)
        builder
            .userDetailsService(userDetailsService)
            .passwordEncoder(passwordEncoder)
        return builder.build()
    }

    @Bean
    fun jwtAuthenticationFilter(userDetailsService: UserDetailsService): JwtAuthenticationFilter =
        JwtAuthenticationFilter(jwtTokenProvider, userDetailsService)

    @Bean
    fun securityFilterChain(
        http: HttpSecurity,
        jwtAuthenticationFilter: JwtAuthenticationFilter,
        userDetailsService: UserDetailsService,
        authenticationEntryPoint: AuthenticationEntryPoint,
        accessDeniedHandler: AccessDeniedHandler,
    ): SecurityFilterChain =
        http
            .csrf { csrf ->
                csrf.ignoringRequestMatchers(*publicPostEndpoints)
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
            }.formLogin { it.disable() }
            .sessionManagement {
                it.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            }.logout { logout ->
                logout.permitAll()
            }.httpBasic { it.disable() }
            .build()

    @Bean
    fun accessDeniedHandler(): AccessDeniedHandler = CustomAccessDeniedHandler()

    @Bean
    fun authenticationEntryPoint(): AuthenticationEntryPoint = CustomAuthenticationEntryPoint()
}
