package place.tomo.infra.config.security

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.access.AccessDeniedHandler

@Configuration
class SecurityFilterChainConfig {
    private val publicPostEndpoints =
        arrayOf(
            "/api/auth/signup",
            "/api/auth/refresh",
        )

    private val apiDocsEndpoints =
        arrayOf(
            "/swagger-ui/**",
            "/swagger-ui.html",
            "/v3/api-docs/**",
        )

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
                    .requestMatchers(*apiDocsEndpoints)
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
