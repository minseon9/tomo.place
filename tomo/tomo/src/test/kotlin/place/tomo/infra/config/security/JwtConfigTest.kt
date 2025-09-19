package place.tomo.infra.config.security

import io.mockk.every
import io.mockk.mockk
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.junit.jupiter.api.extension.ExtendWith
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.ApplicationContext
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.FilterType
import org.springframework.context.annotation.Import
import org.springframework.context.annotation.Primary
import org.springframework.core.convert.converter.Converter
import org.springframework.security.authentication.AbstractAuthenticationToken
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.TestPropertySource
import org.springframework.test.context.junit.jupiter.SpringExtension
import place.tomo.auth.domain.dtos.JwtPropertiesDTO
import place.tomo.auth.domain.exception.InvalidJwtSecretException
import place.tomo.auth.domain.services.jwt.JwtProvider
import place.tomo.common.exception.NotFoundActiveUserException
import place.tomo.contract.dtos.AuthorizedUserDTO
import place.tomo.contract.dtos.UserInfoDTO
import place.tomo.contract.ports.UserDomainPort
import java.time.Instant
import java.util.UUID

@TestConfiguration
class MockConfig {
    @Bean
    @Primary
    fun mockUserDomainPort(): UserDomainPort = mockk()
}

@ExtendWith(SpringExtension::class)
@ContextConfiguration(classes = [JwtConfig::class])
@EnableConfigurationProperties(JwtPropertiesDTO::class)
@TestPropertySource(locations = ["classpath:application-test.properties"])
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
@Import(MockConfig::class)
@DisplayName("JwtConfigTest")
class JwtConfigTest {
    @Autowired
    private lateinit var applicationContext: ApplicationContext

    @Autowired
    private lateinit var jwtEncoder: JwtEncoder

    @Autowired
    private lateinit var jwtDecoder: JwtDecoder

    @Autowired
    private lateinit var jwtAuthenticationConverter: Converter<Jwt, out UsernamePasswordAuthenticationToken>

    @Autowired
    private lateinit var jwtPropertiesDTO: JwtPropertiesDTO

    @Autowired
    private lateinit var jwtProvider: JwtProvider

    @Autowired
    private lateinit var userDomainPort: UserDomainPort

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

            val jwtAuthenticationConverter = applicationContext.getBean(Converter::class.java)
            assertThat(jwtAuthenticationConverter).isNotNull()
            assertThat(jwtAuthenticationConverter).isInstanceOf(Converter::class.java)
        }
    }

    @Nested
    @DisplayName("JwtEncoder")
    inner class JwtEncoderTest {
        @Test
        @DisplayName("jwt secret의 길이가 32byte 미만인 경우 오류 처리")
        fun `jwt encoder when jwt secret length is less thatn 32byte expect exception`() {
            // Given
            val shortSecret = "short"
            val jwtConfigWithShortSecret = JwtConfig(jwtPropertiesDTO, shortSecret, userDomainPort)

            // When & Then
            assertThatThrownBy { jwtConfigWithShortSecret.jwtEncoder() }
                .isInstanceOf(InvalidJwtSecretException::class.java)
        }

        @Test
        @DisplayName("유효한 길이의 시크릿으로 JwtEncoder 생성 성공")
        fun `jwtConfig when valid secret length expect successful jwtEncoder creation`() {
            // Given
            val validSecret = "this-is-a-valid-secret-key-with-32-characters-or-more"
            val jwtConfigWithValidSecret = JwtConfig(jwtPropertiesDTO, validSecret, userDomainPort)

            // When & Then
            assertDoesNotThrow { jwtConfigWithValidSecret.jwtEncoder() }
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

    @Nested
    @DisplayName("JwtAuthenticationConverter")
    inner class JwtAuthenticationConverterTest {
        @Test
        @DisplayName("jwt subject에 해당하는 사용자가 없는 경우, 오류 처리")
        fun `converter when no user corresponding subject expect exception`() {
            val noUserSubject = faker.internet().uuid()
            val mockJwt =
                mockk<Jwt> {
                    every { subject } returns noUserSubject
                }

            every { userDomainPort.findActiveByEntityId(noUserSubject) } returns null

            assertThatThrownBy { jwtAuthenticationConverter.convert(mockJwt) }
                .isInstanceOf(NotFoundActiveUserException::class.java)
        }

        @Test
        @DisplayName("jwt subject에 해당하는 사용자가 비활성화인 경우, 오류 처리")
        fun `converter when deactivated user corresponding subject expect exception`() {
            val deactivatedUserSubject = faker.internet().uuid()
            val mockJwt =
                mockk<Jwt> {
                    every { subject } returns deactivatedUserSubject
                }
            every { userDomainPort.findActiveByEntityId(deactivatedUserSubject) } throws
                NotFoundActiveUserException(faker.internet().emailAddress())

            assertThatThrownBy { jwtAuthenticationConverter.convert(mockJwt) }
                .isInstanceOf(NotFoundActiveUserException::class.java)
        }

        @Test
        @DisplayName("jwt subject가 유효한 사용자인 경우, AbstractAuthenticationToken 생성")
        fun `converter when valid subject and usre expect AbstractAuthenticationToken`() {
            val validSubject = faker.internet().uuid()
            val mockJwt =
                mockk<Jwt> {
                    every { subject } returns validSubject
                }
            val foundActiveUser =
                UserInfoDTO(
                    id = faker.random().nextLong(),
                    entityId = UUID.fromString(validSubject),
                    email = faker.internet().emailAddress(),
                    name = faker.name().username(),
                )

            every { userDomainPort.findActiveByEntityId(validSubject) } returns foundActiveUser

            val authenticationToken = jwtAuthenticationConverter.convert(mockJwt)
            assertThat(authenticationToken).isInstanceOf(UsernamePasswordAuthenticationToken::class.java)
            assertThat(authenticationToken!!.principal).isInstanceOf(AuthorizedUserDTO::class.java)
            assertThat(
                authenticationToken.principal,
            ).isEqualTo(AuthorizedUserDTO(foundActiveUser.id, foundActiveUser.email, foundActiveUser.entityId.toString()))
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
