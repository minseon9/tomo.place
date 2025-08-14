package place.tomo.auth.infra.scheduling

import kotlinx.coroutines.runBlocking
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import place.tomo.auth.domain.services.oidc.discovery.OIDCEndpointResolver
import place.tomo.auth.domain.services.oidc.discovery.OIDCJwksResolver
import place.tomo.contract.constant.OIDCProviderType

@Component
class OIDCCacheWarmup(
    private val endpointResolver: OIDCEndpointResolver,
    private val jwksResolver: OIDCJwksResolver,
) : ApplicationRunner {
    override fun run(args: ApplicationArguments) =
        runBlocking {
            OIDCProviderType.entries.forEach { provider ->
                runCatching {
                    endpointResolver.refresh(provider)
                    jwksResolver.refresh(provider)
                }
            }
        }

    // 한국 시간 자정 기준으로 매일 리프레시
    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Seoul")
    fun scheduledRefresh() =
        runBlocking {
            OIDCProviderType.entries.forEach { provider ->
                runCatching {
                    endpointResolver.refresh(provider)
                    jwksResolver.refresh(provider)
                }
            }
        }
}
