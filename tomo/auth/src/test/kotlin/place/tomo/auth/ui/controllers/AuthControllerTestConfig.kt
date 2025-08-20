package place.tomo.auth.ui.controllers

import io.mockk.mockk
import org.springframework.boot.SpringBootConfiguration
import org.springframework.boot.autoconfigure.EnableAutoConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.Import
import org.springframework.context.annotation.Primary
import place.tomo.auth.application.services.AuthApplicationService
import place.tomo.auth.application.services.OIDCApplicationService
import place.tomo.common.test.security.TestSecurityConfig

@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan(
    basePackages = [
        "place.tomo.auth.ui",
        "place.tomo.common.test.security",
        "place.tomo.common.exception",
    ],
)
@Import(TestSecurityConfig::class)
class AuthControllerTestConfig {
    @Bean
    @Primary
    fun authApplicationService(): AuthApplicationService = mockk()

    @Bean
    @Primary
    fun oidcApplicationService(): OIDCApplicationService = mockk()
}
