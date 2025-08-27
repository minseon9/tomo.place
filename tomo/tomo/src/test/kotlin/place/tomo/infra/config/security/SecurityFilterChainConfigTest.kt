package place.tomo.infra.config.security

import io.mockk.every
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration
import org.springframework.boot.autoconfigure.web.reactive.WebFluxAutoConfiguration
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.context.ApplicationContext
import org.springframework.http.MediaType
import org.springframework.mock.web.MockHttpSession
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.access.AccessDeniedHandler
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import org.springframework.test.web.servlet.setup.DefaultMockMvcBuilder
import org.springframework.test.web.servlet.setup.MockMvcBuilders
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.context.WebApplicationContext
import place.tomo.auth.application.services.CustomUserDetailsService
import place.tomo.auth.domain.services.JwtProvider
import place.tomo.auth.ui.controllers.AuthController
import place.tomo.auth.ui.controllers.OIDCController
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserDomainPort

@RestController
class DummyController {
    @PostMapping("/need-authentication")
    fun needAuthenticationPost() {}

    @GetMapping("/need-authentication")
    fun needAuthenticationGet() {}

    @PostMapping(
        "/api/auth/login",
        "/api/auth/signup",
        "/api/oidc/login",
        "/api/oidc/signup",
    )
    fun postAllAllowed() {}
}

@WebMvcTest(
    controllers = [DummyController::class, AuthController::class, OIDCController::class],
    excludeAutoConfiguration = [
        HibernateJpaAutoConfiguration::class,
        JpaRepositoriesAutoConfiguration::class,
        WebFluxAutoConfiguration::class,
    ],
)
@ActiveProfiles("test")
@ContextConfiguration(classes = [SecurityFilterChainConfigTestConfig::class])
@DisplayName("SecurityFilterChainConfigTest")
class SecurityFilterChainConfigTest {
    @Autowired
    private lateinit var webApplicationContext: WebApplicationContext

    @Autowired
    private lateinit var applicationContext: ApplicationContext

    @Autowired
    private lateinit var jwtProvider: JwtProvider

    @Autowired
    private lateinit var userDomainPort: UserDomainPort

    private lateinit var mockMvc: MockMvc

    private val faker = Faker()

    private val publicPostEndpoints =
        arrayOf(
            "/api/auth/login",
            "/api/auth/signup",
            "/api/oidc/login",
            "/api/oidc/signup",
        )

    @BeforeEach
    fun setUp() {
        mockMvc =
            MockMvcBuilders
                .webAppContextSetup(webApplicationContext)
                .apply<DefaultMockMvcBuilder>(SecurityMockMvcConfigurers.springSecurity())
                .build()
    }

    @Nested
    @DisplayName("Bean Configuration Verification")
    inner class BeanConfigurationTest {
        @Test
        @DisplayName("SecurityFilterChainConfig에서 정의된 빈들이 올바른 타입으로 주입됨")
        fun `securityConfig when beans created expect all beans injected with correct types`() {
            val securityFilterChainConfig = applicationContext.getBean(SecurityFilterChainConfig::class.java)
            assertThat(securityFilterChainConfig).isNotNull()

            val authenticationEntryPoint = applicationContext.getBean(AuthenticationEntryPoint::class.java)
            assertThat(authenticationEntryPoint).isNotNull()
            assertThat(authenticationEntryPoint).isInstanceOf(CustomAuthenticationEntryPoint::class.java)

            val accessDeniedHandler = applicationContext.getBean(AccessDeniedHandler::class.java)
            assertThat(accessDeniedHandler).isNotNull()
            assertThat(accessDeniedHandler).isInstanceOf(CustomAccessDeniedHandler::class.java)

            val securityFilterChain = applicationContext.getBean(SecurityFilterChain::class.java)
            assertThat(securityFilterChain).isNotNull()
            assertThat(securityFilterChain).isInstanceOf(SecurityFilterChain::class.java)

            val userDetailsService = applicationContext.getBean(UserDetailsService::class.java)
            assertThat(userDetailsService).isNotNull()
            assertThat(userDetailsService).isInstanceOf(CustomUserDetailsService::class.java)
        }
    }

    @Nested
    @DisplayName("SecurityFilterChain Integration")
    inner class SecurityFilterChainIntegrationTest {
        @Test
        @DisplayName("공개 엔드포인트는 인증 없이 접근 가능")
        fun `filterChain when public endpoints expect access without authentication`() {
            publicPostEndpoints.forEach { endpoint ->
                mockMvc
                    .perform(
                        MockMvcRequestBuilders
                            .post(endpoint)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{}"),
                    ).andExpect(MockMvcResultMatchers.status().isOk)
            }
        }

        @Test
        @DisplayName("보호된 엔드포인트는 인증 필요")
        fun `filterChain when protected endpoints expect authentication required`() {
            mockMvc
                .perform(MockMvcRequestBuilders.post("/need-authentication"))
                .andExpect(MockMvcResultMatchers.status().isUnauthorized)
        }

        @Test
        @DisplayName("유효한 JWT 토큰으로 보호된 엔드포인트 접근 가능")
        fun `filterChain when valid jwt token expect access to protected endpoints`() {
            val token = createAuthenticatedUser()

            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/need-authentication")
                        .header("Authorization", "Bearer $token"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
        }

        @Test
        @DisplayName("잘못된 JWT 토큰으로는 접근 불가")
        fun `filterChain when invalid jwt token expect access denied`() {
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/need-authentication")
                        .header("Authorization", "Bearer invalid.token.here"),
                ).andExpect(MockMvcResultMatchers.status().isUnauthorized)
        }

        @Test
        @DisplayName("세션 관리가 STATELESS로 설정됨")
        fun `filterChain when any request expect stateless session`() {
            val result =
                mockMvc
                    .perform(MockMvcRequestBuilders.post("/need-authentication"))
                    .andReturn()

            assertThat(result.request.getSession(false)).isNull()
            assertThat(result.response.getHeader("Set-Cookie")).isNull()
        }

        @Test
        @DisplayName("HTTP Basic 인증이 비활성화됨")
        fun `filterChain when basic auth expect disabled`() {
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/need-authentication")
                        .header("Authorization", "Basic dGVzdDp0ZXN0"),
                ).andExpect(MockMvcResultMatchers.status().isUnauthorized)
        }

        @Test
        @DisplayName("Form 로그인이 비활성화됨")
        fun `filterChain when form login expect disabled`() {
            val token = createAuthenticatedUser()

            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/login")
                        .header("Authorization", "Bearer $token"),
                ).andExpect(MockMvcResultMatchers.status().isNotFound)
        }
    }

    private fun createAuthenticatedUser(): String {
        val email = faker.internet().emailAddress()
        val token = jwtProvider.issueAccessToken(email)

        every { userDomainPort.findActiveByEmail(email) } returns
            UserInfoDTO(
                id = faker.number().randomNumber(),
                email = email,
                password = faker.internet().password(),
                name = faker.name().username(),
            )

        return token
    }
}
