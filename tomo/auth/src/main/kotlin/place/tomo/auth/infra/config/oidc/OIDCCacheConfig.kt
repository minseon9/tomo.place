package place.tomo.auth.infra.config.oidc

import com.github.benmanes.caffeine.cache.Caffeine
import org.springframework.cache.CacheManager
import org.springframework.cache.annotation.EnableCaching
import org.springframework.cache.caffeine.CaffeineCacheManager
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.scheduling.annotation.EnableScheduling
import java.util.concurrent.TimeUnit

@Configuration
@EnableCaching
@EnableScheduling
class OIDCCacheConfig {
    @Bean
    fun cacheManager(): CacheManager =
        CaffeineCacheManager("oidc-endpoints", "oidc-jwks").apply {
            setCaffeine(
                Caffeine
                    .newBuilder()
                    .maximumSize(100)
                    .expireAfterWrite(24, TimeUnit.HOURS),
            )
        }
}
