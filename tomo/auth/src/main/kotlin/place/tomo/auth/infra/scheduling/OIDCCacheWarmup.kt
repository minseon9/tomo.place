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
                }
                runCatching {
                    jwksResolver.refresh(provider)
                }
            }
        }

    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Seoul")
    fun scheduledRefresh() =
        runBlocking {
            OIDCProviderType.entries.forEach { provider ->
                runCatching {
                    endpointResolver.refresh(provider)
                }
                runCatching {
                    jwksResolver.refresh(provider)
                }
            }
        }
}
