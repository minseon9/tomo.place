package place.tomo.infra.config.security

import io.mockk.mockk
import org.springframework.boot.SpringBootConfiguration
import org.springframework.boot.autoconfigure.EnableAutoConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.FilterType
import org.springframework.context.annotation.Primary
import place.tomo.auth.application.services.CustomUserDetailsService
import place.tomo.auth.domain.services.JwtProvider
import place.tomo.contract.ports.UserDomainPort
import place.tomo.infra.config.PasswordConfig

@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan(
    basePackages = [
        "place.tomo.auth.application.services",
        "place.tomo.auth.domain.services",
        "place.tomo.infra.config.security",
        "place.tomo.infra.config",
    ],
    includeFilters = [
        ComponentScan.Filter(
            type = FilterType.ASSIGNABLE_TYPE,
            classes = [
                SecurityFilterChainConfig::class,
                PasswordConfig::class,
                JwtProvider::class,
                CustomUserDetailsService::class,
                CustomAuthenticationEntryPoint::class,
                CustomAccessDeniedHandler::class,
            ],
        ),
    ],
    excludeFilters = [
        ComponentScan.Filter(
            type = FilterType.REGEX,
            pattern = [
                "place\\.tomo\\.auth\\.domain\\.services\\.(?!JwtProvider).*",
                "place\\.tomo\\.auth\\.application\\.services\\.(?!CustomUserDetailsService).*",
                "place\\.tomo\\.infra\\.config\\.(?!PasswordConfig|security).*",
            ],
        ),
    ],
)
class SecurityFilterChainConfigTestConfig {
    @Bean
    @Primary
    fun userDomainPort(): UserDomainPort = mockk()
}
