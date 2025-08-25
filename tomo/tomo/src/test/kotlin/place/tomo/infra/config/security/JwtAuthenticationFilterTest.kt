package place.tomo.infra.config.security

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import net.datafaker.Faker
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.mock.web.MockHttpServletRequest
import org.springframework.mock.web.MockHttpServletResponse
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import place.tomo.auth.domain.exception.InvalidAuthTokenException
import place.tomo.auth.domain.services.JwtTokenProvider

@DisplayName("JwtAuthenticationFilter")
class JwtAuthenticationFilterTest {
    private val faker = Faker()
    private lateinit var jwtTokenProvider: JwtTokenProvider
    private lateinit var userDetailsService: UserDetailsService
    private lateinit var request: HttpServletRequest
    private lateinit var response: HttpServletResponse
    private lateinit var filterChain: FilterChain
    private lateinit var jwtAuthenticationFilter: JwtAuthenticationFilter

    @BeforeEach
    fun setUp() {
        jwtTokenProvider = mockk()
        userDetailsService = mockk()
        jwtAuthenticationFilter = JwtAuthenticationFilter(jwtTokenProvider, userDetailsService)
        response = MockHttpServletResponse()
        filterChain = mockk(relaxed = true)
        SecurityContextHolder.clearContext()
    }

    @Nested
    @DisplayName("Authorization Header 처리")
    inner class AuthorizationHeaderContext {
        @Test
        @DisplayName("Authorization 헤더가 없을 때 인증 실패")
        fun `should fail authentication when no authorization header`() {
            // Given
            request = MockHttpServletRequest()

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { filterChain.doFilter(request, response) }
            verify(exactly = 0) { jwtTokenProvider.validateToken(any()) }
            verify(exactly = 0) { userDetailsService.loadUserByUsername(any()) }
            assertThat(SecurityContextHolder.getContext().authentication).isNull()
        }

        @Test
        @DisplayName("Authorization 헤더가 빈 값일 때 인증 실패")
        fun `should fail authentication when authorization header is empty`() {
            // Given
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "")
                }

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { filterChain.doFilter(request, response) }
            verify(exactly = 0) { jwtTokenProvider.validateToken(any()) }
            verify(exactly = 0) { userDetailsService.loadUserByUsername(any()) }
            assertThat(SecurityContextHolder.getContext().authentication).isNull()
        }

        @Test
        @DisplayName("Bearer 토큰 형식이 아닐 때 인증 실패")
        fun `should fail authentication when token is not bearer format`() {
            // Given
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Basic dGVzdDp0ZXN0")
                }

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { filterChain.doFilter(request, response) }
            verify(exactly = 0) { jwtTokenProvider.validateToken(any()) }
            verify(exactly = 0) { userDetailsService.loadUserByUsername(any()) }
            assertThat(SecurityContextHolder.getContext().authentication).isNull()
        }

        @Test
        @DisplayName("Bearer 접두사만 있고 토큰이 없을 때 인증 실패")
        fun `should fail authentication when bearer prefix exists but no token`() {
            // Given
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer ")
                }

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { filterChain.doFilter(request, response) }
            verify(exactly = 0) { jwtTokenProvider.validateToken(any()) }
            verify(exactly = 0) { userDetailsService.loadUserByUsername(any()) }
            assertThat(SecurityContextHolder.getContext().authentication).isNull()
        }

        @Test
        @DisplayName("Bearer 토큰 형식이 정상일 때 토큰 추출 성공")
        fun `should extract token when bearer format is correct`() {
            // Given
            val token = faker.internet().uuid()
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns true
            every { jwtTokenProvider.getUsernameFromToken(token) } returns faker.internet().emailAddress()
            every { userDetailsService.loadUserByUsername(any()) } returns createUserDetails(faker.internet().emailAddress())

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { jwtTokenProvider.validateToken(token) }
            verify { filterChain.doFilter(request, response) }
        }
    }

    @Nested
    @DisplayName("JWT Token 검증")
    inner class JwtTokenValidationContext {
        @Test
        @DisplayName("유효한 JWT 토큰일 때 검증 성공")
        fun `should validate token successfully when token is valid`() {
            // Given
            val token = faker.internet().uuid()
            val username = faker.internet().emailAddress()
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns true
            every { jwtTokenProvider.getUsernameFromToken(token) } returns username
            every { userDetailsService.loadUserByUsername(username) } returns createUserDetails(username)

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { jwtTokenProvider.validateToken(token) }
            verify { jwtTokenProvider.getUsernameFromToken(token) }
            verify { userDetailsService.loadUserByUsername(username) }
            verify { filterChain.doFilter(request, response) }
        }

        @Test
        @DisplayName("유효하지 않은 JWT 토큰일 때 검증 실패")
        fun `should fail validation when token is invalid`() {
            // Given
            val token = faker.internet().uuid()
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns false

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { jwtTokenProvider.validateToken(token) }
            verify(exactly = 0) { jwtTokenProvider.getUsernameFromToken(any()) }
            verify(exactly = 0) { userDetailsService.loadUserByUsername(any()) }
            verify { filterChain.doFilter(request, response) }
            assertThat(SecurityContextHolder.getContext().authentication).isNull()
        }
    }

    @Nested
    @DisplayName("UserDetails 로드")
    inner class UserDetailsLoadingContext {
        @Test
        @DisplayName("사용자 정보 로드 성공 시 인증 객체 생성")
        fun `should create authentication when user details loaded successfully`() {
            // Given
            val token = faker.internet().uuid()
            val username = faker.internet().emailAddress()
            val userDetails = createUserDetails(username)
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns true
            every { jwtTokenProvider.getUsernameFromToken(token) } returns username
            every { userDetailsService.loadUserByUsername(username) } returns userDetails

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { userDetailsService.loadUserByUsername(username) }
            val authentication = SecurityContextHolder.getContext().authentication
            assertThat(authentication).isNotNull()
            assertThat(authentication.principal).isEqualTo(userDetails)
            assertThat(authentication.isAuthenticated).isTrue()
            assertThat(authentication.authorities.toString()).isEqualTo(userDetails.authorities.toString())
        }

        @Test
        @DisplayName("사용자 정보 로드 실패 시 인증 컨텍스트 설정 안함")
        fun `should not set authentication context when user details loading fails`() {
            // Given
            val token = faker.internet().uuid()
            val username = faker.internet().emailAddress()
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns true
            every { jwtTokenProvider.getUsernameFromToken(token) } returns username
            every { userDetailsService.loadUserByUsername(username) } throws UsernameNotFoundException("User not found")

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { userDetailsService.loadUserByUsername(username) }
            verify { filterChain.doFilter(request, response) }
            assertThat(SecurityContextHolder.getContext().authentication).isNull()
        }

        @Test
        @DisplayName("사용자 정보 로드 중 예외 발생 시 인증 실패")
        fun `should fail authentication when user details loading throws exception`() {
            val token = faker.internet().uuid()
            val username = faker.internet().emailAddress()
            val userDetails = createUserDetails(username)
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns true
            every { jwtTokenProvider.getUsernameFromToken(token) } throws InvalidAuthTokenException()
            every { userDetailsService.loadUserByUsername(username) } returns userDetails

            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            assertThrows<RuntimeException> { jwtTokenProvider.getUsernameFromToken(token) }
            verify(exactly = 0) { userDetailsService.loadUserByUsername(username) }
            verify { filterChain.doFilter(request, response) }
            assertThat(SecurityContextHolder.getContext().authentication).isNull()
        }
    }

    @Nested
    @DisplayName("Security Context 설정")
    inner class SecurityContextContext {
        @Test
        @DisplayName("인증 성공 시 SecurityContext에 인증 객체 설정")
        fun `should set authentication in security context when authentication succeeds`() {
            // Given
            val token = faker.internet().uuid()
            val username = faker.internet().emailAddress()
            val userDetails = createUserDetails(username)
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns true
            every { jwtTokenProvider.getUsernameFromToken(token) } returns username
            every { userDetailsService.loadUserByUsername(username) } returns userDetails

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            val authentication = SecurityContextHolder.getContext().authentication
            assertThat(authentication).isNotNull()
            assertThat(authentication.principal).isEqualTo(userDetails)
            assertThat(authentication.isAuthenticated).isTrue()
            assertThat(authentication.authorities.toString()).isEqualTo(userDetails.authorities.toString())
        }

        @Test
        @DisplayName("인증 실패 시 SecurityContext에 인증 객체 설정 안함")
        fun `should not set authentication in security context when authentication fails`() {
            // Given
            val token = faker.internet().uuid()
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns false

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            assertThat(SecurityContextHolder.getContext().authentication).isNull()
        }

        @Test
        @DisplayName("기존 인증 컨텍스트가 있을 때 새로운 인증으로 교체")
        fun `should replace existing authentication context with new authentication`() {
            // Given
            val existingUserDetails = createUserDetails("existing@example.com")
            val existingAuth =
                org.springframework.security.authentication.UsernamePasswordAuthenticationToken(
                    existingUserDetails,
                    null,
                    existingUserDetails.authorities,
                )
            SecurityContextHolder.getContext().authentication = existingAuth

            val token = faker.internet().uuid()
            val username = faker.internet().emailAddress()
            val newUserDetails = createUserDetails(username)
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns true
            every { jwtTokenProvider.getUsernameFromToken(token) } returns username
            every { userDetailsService.loadUserByUsername(username) } returns newUserDetails

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            val authentication = SecurityContextHolder.getContext().authentication
            assertThat(authentication).isNotNull()
            assertThat(authentication.principal).isEqualTo(newUserDetails)
            assertThat(authentication.principal).isNotEqualTo(existingUserDetails)
        }
    }

    @Nested
    @DisplayName("Filter Chain 처리")
    inner class FilterChainContext {
        @Test
        @DisplayName("인증 성공 시에도 필터 체인 계속 실행")
        fun `should continue filter chain even when authentication succeeds`() {
            // Given
            val token = faker.internet().uuid()
            val username = faker.internet().emailAddress()
            val userDetails = createUserDetails(username)
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns true
            every { jwtTokenProvider.getUsernameFromToken(token) } returns username
            every { userDetailsService.loadUserByUsername(username) } returns userDetails

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { filterChain.doFilter(request, response) }
        }

        @Test
        @DisplayName("인증 실패 시에도 필터 체인 계속 실행")
        fun `should continue filter chain even when authentication fails`() {
            // Given
            val token = faker.internet().uuid()
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns false

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { filterChain.doFilter(request, response) }
        }
    }

    @Nested
    @DisplayName("통합 시나리오")
    inner class IntegrationScenarios {
        @Test
        @DisplayName("완전한 인증 플로우 성공")
        fun `should complete full authentication flow successfully`() {
            // Given
            val token = faker.internet().uuid()
            val username = faker.internet().emailAddress()
            val userDetails = createUserDetails(username)
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns true
            every { jwtTokenProvider.getUsernameFromToken(token) } returns username
            every { userDetailsService.loadUserByUsername(username) } returns userDetails

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { jwtTokenProvider.validateToken(token) }
            verify { jwtTokenProvider.getUsernameFromToken(token) }
            verify { userDetailsService.loadUserByUsername(username) }
            verify { filterChain.doFilter(request, response) }

            val authentication = SecurityContextHolder.getContext().authentication
            assertThat(authentication).isNotNull()
            assertThat(authentication.principal).isEqualTo(userDetails)
            assertThat(authentication.isAuthenticated).isTrue()
        }

        @Test
        @DisplayName("토큰 검증 실패로 인한 인증 플로우 중단")
        fun `should stop authentication flow when token validation fails`() {
            // Given
            val token = faker.internet().uuid()
            request =
                MockHttpServletRequest().apply {
                    addHeader("Authorization", "Bearer $token")
                }
            every { jwtTokenProvider.validateToken(token) } returns false

            // When
            jwtAuthenticationFilter.doFilter(request, response, filterChain)

            // Then
            verify { jwtTokenProvider.validateToken(token) }
            verify(exactly = 0) { jwtTokenProvider.getUsernameFromToken(any()) }
            verify(exactly = 0) { userDetailsService.loadUserByUsername(any()) }
            verify { filterChain.doFilter(request, response) }
            assertThat(SecurityContextHolder.getContext().authentication).isNull()
        }
    }

    private fun createUserDetails(username: String): UserDetails =
        User
            .builder()
            .username(username)
            .password("password")
            .authorities("USER")
            .build()
}
