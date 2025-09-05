package place.tomo.infra.config.security

import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.ApplicationContext
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.FilterType
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.TestPropertySource
import org.springframework.test.context.junit.jupiter.SpringExtension
import place.tomo.auth.domain.dtos.JwtPropertiesDTO
import place.tomo.auth.domain.services.jwt.JwtProvider
import java.time.Instant

@ExtendWith(SpringExtension::class)
@ContextConfiguration(classes = [JwtConfig::class])
@EnableConfigurationProperties(JwtPropertiesDTO::class)
@TestPropertySource(locations = ["classpath:application-test.properties"]) // 명시적으로 추가
@ComponentScan(
    basePackages = [
        "place.tomo.auth.domain.services.jwt",
    ],
    excludeFilters = [
        ComponentScan.Filter(
            type = FilterType.REGEX,
            pattern = [
                "place\\.tomo\\.auth\\.domain\\.services\\.jwt\\.(?!JwtProvider).*",
            ],
        ),
    ],
)
@DisplayName("JwtConfigTest")
class JwtConfigTest {
    @Autowired
    private lateinit var applicationContext: ApplicationContext

    @Autowired
    private lateinit var jwtEncoder: JwtEncoder

    @Autowired
    private lateinit var jwtDecoder: JwtDecoder

    @Autowired
    private lateinit var jwtPropertiesDTO: JwtPropertiesDTO

    @Autowired
    private lateinit var jwtProvider: JwtProvider

    private val faker = Faker()

    @BeforeEach
    fun setUp() {
        jwtProvider = JwtProvider(jwtPropertiesDTO, jwtEncoder)
    }

    @Nested
    @DisplayName("Bean Configuration")
    inner class BeanConfigurationTest {
        @Test
        @DisplayName("JwtConfig에서 정의된 빈들이 올바른 타입으로 주입됨")
        fun `securityConfig when beans created expect all beans injected with correct types`() {
            val jwtEncoder = applicationContext.getBean(JwtEncoder::class.java)
            assertThat(jwtEncoder).isNotNull()
            assertThat(jwtEncoder).isInstanceOf(NimbusJwtEncoder::class.java)

            val jwtDecoder = applicationContext.getBean(JwtDecoder::class.java)
            assertThat(jwtDecoder).isNotNull()
            assertThat(jwtDecoder).isInstanceOf(NimbusJwtDecoder::class.java)
        }
    }

    @Nested
    @DisplayName("JwtDecoder")
    inner class JwtDecoderTest {
        @Test
        @DisplayName("유효한 JWT 토큰으로 보호된 엔드포인트 접근 가능")
        fun `filterChain when valid jwt token expect access to protected endpoints`() {
            val subject = faker.internet().emailAddress()
            val jwtToken = jwtProvider.issueAccessToken(subject)

            val result = jwtDecoder.decode(jwtToken.token)

            assertThat(result.getClaimAsString("iss")).isEqualTo(jwtPropertiesDTO.issuer)
            assertThat(result.audience).isEqualTo(jwtPropertiesDTO.audiences)
            assertThat(result.expiresAt).isAfter(Instant.now())
            assertThat(result.subject).isEqualTo(subject)
        }

        @Test
        @DisplayName("유효기간이 지난 JWT 토큰으로는 접근 불가")
        fun `filterChain when expired token expect access denied`() {
            jwtProvider = createJwtProvider(accessTtlSeconds = -10000L)
            val jwtToken = jwtProvider.issueAccessToken(faker.internet().emailAddress())

            assertThatThrownBy { jwtDecoder.decode(jwtToken.token) }
        }

        @Test
        @DisplayName("issuer가 유효하지 않은 경우 접근 불가")
        fun `filterChain when invalid issuer token expect access denied`() {
            jwtProvider = createJwtProvider(issuer = "invalid issuer")
            val jwtToken = jwtProvider.issueAccessToken(faker.internet().emailAddress())

            assertThatThrownBy { jwtDecoder.decode(jwtToken.token) }
        }

        @Test
        @DisplayName("audience가 유효하지 않은 경우 접근 불가")
        fun `filterChain when invalid audience token expect access denied`() {
            jwtProvider = createJwtProvider(audiences = listOf("invalid audience"))
            val jwtToken = jwtProvider.issueAccessToken(faker.internet().emailAddress())

            assertThatThrownBy { jwtDecoder.decode(jwtToken.token) }
        }
    }

    private fun createJwtProvider(
        issuer: String? = null,
        audiences: List<String>? = null,
        accessTtlSeconds: Long? = null,
        refreshTtlSeconds: Long? = null,
    ): JwtProvider {
        val mockedProperties =
            JwtPropertiesDTO(
                issuer = issuer ?: jwtPropertiesDTO.issuer,
                audiences = audiences ?: jwtPropertiesDTO.audiences,
                accessTtlSeconds = accessTtlSeconds ?: jwtPropertiesDTO.accessTtlSeconds,
                refreshTtlSeconds = refreshTtlSeconds ?: jwtPropertiesDTO.refreshTtlSeconds,
            )

        return JwtProvider(mockedProperties, jwtEncoder)
    }
}
