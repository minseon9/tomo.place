package place.tomo.infra.config.security

import org.springframework.boot.SpringBootConfiguration
import org.springframework.boot.autoconfigure.EnableAutoConfiguration
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.FilterType
import place.tomo.auth.domain.dtos.JwtPropertiesDTO
import place.tomo.auth.domain.services.jwt.JwtProvider
import place.tomo.infra.config.PasswordConfig

@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan(
    basePackages = [
        "place.tomo.auth.domain.services.jwt",
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
                CustomAuthenticationEntryPoint::class,
                CustomAccessDeniedHandler::class,
            ],
        ),
    ],
    excludeFilters = [
        ComponentScan.Filter(
            type = FilterType.REGEX,
            pattern = [
                "place\\.tomo\\.auth\\.domain\\.services\\.jwt\\.(?!JwtProvider).*",
                "place\\.tomo\\.infra\\.config\\.(?!PasswordConfig|security).*",
            ],
        ),
    ],
)
@EnableConfigurationProperties(JwtPropertiesDTO::class)
class SecurityFilterChainConfigTestConfig
