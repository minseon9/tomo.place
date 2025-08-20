package place.tomo.common.test.security

import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Import
import org.springframework.context.annotation.Primary
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter

@TestConfiguration
@Import(TestJwtFilter::class)
class TestSecurityConfig(
    private val testJwtFilter: TestJwtFilter,
) {
    private val publicPostEndpoints =
        arrayOf(
            "/api/auth/login",
            "/api/auth/signup",
            "/api/oidc/login",
            "/api/oidc/signup",
        )

    @Bean
    @Primary
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain =
        http
            .csrf { csrf ->
                csrf.ignoringRequestMatchers(*publicPostEndpoints)
            }.authorizeHttpRequests { auth ->
                auth
                    .requestMatchers(HttpMethod.POST, *publicPostEndpoints)
                    .permitAll()
                    .anyRequest()
                    .authenticated()
            }.formLogin { it.disable() }
            .sessionManagement {
                it.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            }.addFilterBefore(testJwtFilter, UsernamePasswordAuthenticationFilter::class.java)
            .logout { logout ->
                logout.permitAll()
            }.httpBasic { it.disable() }
            .build()
}
