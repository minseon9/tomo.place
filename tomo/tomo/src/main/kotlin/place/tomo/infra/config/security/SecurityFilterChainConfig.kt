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
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.access.AccessDeniedHandler

@Configuration
class SecurityFilterChainConfig {
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
    fun securityFilterChain(
        http: HttpSecurity,
        jwtDecoder: JwtDecoder,
        authenticationEntryPoint: AuthenticationEntryPoint,
        accessDeniedHandler: AccessDeniedHandler,
    ): SecurityFilterChain =
        http
            .csrf { csrf ->
                csrf.disable()
            }.authorizeHttpRequests { auth ->
                auth
                    .requestMatchers(HttpMethod.POST, *publicPostEndpoints)
                    .permitAll()
                    .anyRequest()
                    .authenticated()
            }.oauth2ResourceServer { auth ->
                auth.jwt { jwt -> jwt.decoder(jwtDecoder) }
            }.exceptionHandling { exception ->
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
