package place.tomo.auth.infra.scheduling

import io.mockk.coEvery
import io.mockk.coJustRun
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.junit.jupiter.api.assertThrows
import org.springframework.boot.ApplicationArguments
import place.tomo.auth.domain.services.oidc.discovery.OIDCEndpointResolver
import place.tomo.auth.domain.services.oidc.discovery.OIDCJwksResolver
import place.tomo.contract.constant.OIDCProviderType

@DisplayName("OIDCCacheWarmup")
class OIDCCacheWarmupTest {
    private var endpointResolver: OIDCEndpointResolver = mockk()
    private var jwksResolver: OIDCJwksResolver = mockk()
    private var applicationArguments: ApplicationArguments = mockk()
    private var oidcCacheWarmup: OIDCCacheWarmup = OIDCCacheWarmup(endpointResolver, jwksResolver)

    @Nested
    @DisplayName("run")
    inner class Run {
        @Test
        @DisplayName("애플리케이션 시작 시 모든 OIDC Provider 캐시 워밍업")
        fun `run when application starts expect all providers cache warmed up`() {
            coJustRun { endpointResolver.refresh(any()) }
            coJustRun { jwksResolver.refresh(any()) }

            oidcCacheWarmup.run(applicationArguments)

            OIDCProviderType.entries.forEach { provider ->
                runBlocking {
                    coVerify(exactly = 1) { endpointResolver.refresh(provider) }
                    coVerify(exactly = 1) { jwksResolver.refresh(provider) }
                }
            }
        }

        @Test
        @DisplayName("일부 Provider 캐시 워밍업 실패 시에도 다른 Provider는 계속 처리")
        fun `run when some providers fail expect other providers continue`() {
            val failedProvider = OIDCProviderType.GOOGLE
            OIDCProviderType.entries.forEach { provider ->
                if (provider == failedProvider) {
                    coEvery { endpointResolver.refresh(failedProvider) } throws RuntimeException("Google endpoint refresh failed")
                    coEvery { jwksResolver.refresh(failedProvider) } throws RuntimeException("Google JWKS refresh failed")
                } else {
                    coJustRun { endpointResolver.refresh(provider) }
                    coJustRun { jwksResolver.refresh(provider) }
                }
            }

            oidcCacheWarmup.run(applicationArguments)

            OIDCProviderType.entries.filter { it != failedProvider }.forEach { provider ->
                runBlocking {
                    coVerify(exactly = 1) { endpointResolver.refresh(provider) }
                    coVerify(exactly = 1) { jwksResolver.refresh(provider) }
                }
            }
            runBlocking {
                assertThrows<RuntimeException> { endpointResolver.refresh(failedProvider) }
                assertThrows<RuntimeException> { jwksResolver.refresh(failedProvider) }
            }
        }
    }

    @Nested
    @DisplayName("scheduledRefresh")
    inner class ScheduledRefresh {
        @Test
        @DisplayName("스케줄된 리프레시 시 모든 OIDC Provider 캐시 갱신")
        fun `scheduledRefresh when scheduled expect all providers cache refreshed`() {
            coJustRun { endpointResolver.refresh(any()) }
            coJustRun { jwksResolver.refresh(any()) }

            oidcCacheWarmup.scheduledRefresh()

            OIDCProviderType.entries.forEach { provider ->
                runBlocking {
                    coVerify(exactly = 1) { endpointResolver.refresh(provider) }
                    coVerify(exactly = 1) { jwksResolver.refresh(provider) }
                }
            }
        }

        @Test
        @DisplayName("스케줄된 리프레시에서 일부 Provider 실패 시에도 다른 Provider 계속 처리")
        fun `scheduledRefresh when some providers fail expect other providers continue`() {
            val failedProvider = OIDCProviderType.GOOGLE
            OIDCProviderType.entries.forEach { provider ->
                if (provider == failedProvider) {
                    coEvery { endpointResolver.refresh(failedProvider) } throws RuntimeException("Google endpoint refresh failed")
                    coEvery { jwksResolver.refresh(failedProvider) } throws RuntimeException("Google JWKS refresh failed")
                } else {
                    coJustRun { endpointResolver.refresh(provider) }
                    coJustRun { jwksResolver.refresh(provider) }
                }
            }

            oidcCacheWarmup.scheduledRefresh()

            OIDCProviderType.entries.filter { it != failedProvider }.forEach { provider ->
                runBlocking {
                    coVerify(exactly = 1) { endpointResolver.refresh(provider) }
                    coVerify(exactly = 1) { jwksResolver.refresh(provider) }
                }
            }
            runBlocking {
                assertThrows<RuntimeException> { endpointResolver.refresh(failedProvider) }
                assertThrows<RuntimeException> { jwksResolver.refresh(failedProvider) }
            }
        }
    }

    @Nested
    @DisplayName("Error Handling")
    inner class ErrorHandling {
        @Test
        @DisplayName("EndpointResolver 예외 발생 시에도 JWKSResolver는 호출됨")
        fun `run when endpointResolver throws exception expect jwksResolver still called`() {
            val endpointResolveFailedProvider = OIDCProviderType.GOOGLE
            OIDCProviderType.entries.forEach { provider ->
                if (provider == endpointResolveFailedProvider) {
                    coEvery { endpointResolver.refresh(endpointResolveFailedProvider) } throws
                        RuntimeException("endpoint refresh failed")
                    coJustRun { jwksResolver.refresh(endpointResolveFailedProvider) }
                } else {
                    coJustRun { endpointResolver.refresh(provider) }
                    coJustRun { jwksResolver.refresh(provider) }
                }
            }

            oidcCacheWarmup.run(applicationArguments)

            OIDCProviderType.entries.filter { it != endpointResolveFailedProvider }.forEach { provider ->
                runBlocking {
                    coVerify(exactly = 1) { endpointResolver.refresh(provider) }
                    coVerify(exactly = 1) { jwksResolver.refresh(provider) }
                }
            }
            runBlocking {
                assertThrows<RuntimeException> { endpointResolver.refresh(endpointResolveFailedProvider) }
                coVerify(exactly = 1) { jwksResolver.refresh(endpointResolveFailedProvider) }
            }
        }

        @Test
        @DisplayName("JWKSResolver 예외 발생 시에도 EndpointResolver는 호출됨")
        fun `run when jwksResolver throws exception expect endpointResolver still called`() {
            val jwksResolveFailedProvider = OIDCProviderType.GOOGLE
            OIDCProviderType.entries.forEach { provider ->
                if (provider == jwksResolveFailedProvider) {
                    coJustRun { endpointResolver.refresh(jwksResolveFailedProvider) }
                    coEvery { jwksResolver.refresh(jwksResolveFailedProvider) } throws
                        RuntimeException("jwks refresh failed")
                } else {
                    coJustRun { endpointResolver.refresh(provider) }
                    coJustRun { jwksResolver.refresh(provider) }
                }
            }

            oidcCacheWarmup.run(applicationArguments)

            OIDCProviderType.entries.filter { it != jwksResolveFailedProvider }.forEach { provider ->
                runBlocking {
                    coVerify(exactly = 1) { endpointResolver.refresh(provider) }
                    coVerify(exactly = 1) { jwksResolver.refresh(provider) }
                }
            }
            runBlocking {
                coVerify(exactly = 1) { endpointResolver.refresh(jwksResolveFailedProvider) }
                assertThrows<RuntimeException> { jwksResolver.refresh(jwksResolveFailedProvider) }
            }
        }

        @Test
        @DisplayName("모든 Provider에서 예외 발생 시에도 애플리케이션 시작은 계속됨")
        fun `run when all providers fail expect application startup continues`() {
            runBlocking {
                coEvery { endpointResolver.refresh(any()) } throws RuntimeException("All endpoint refresh failed")
                coEvery { jwksResolver.refresh(any()) } throws RuntimeException("All JWKS refresh failed")
            }

            // 예외가 발생해도 애플리케이션 시작은 계속되어야 함
            assertDoesNotThrow { oidcCacheWarmup.run(applicationArguments) }

            OIDCProviderType.entries.forEach { provider ->
                runBlocking {
                    assertThrows<RuntimeException> { endpointResolver.refresh(provider) }
                    assertThrows<RuntimeException> { jwksResolver.refresh(provider) }
                }
            }
        }
    }
}
