package place.tomo.infra.config.cache.oidc

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.cache.CacheManager
import org.springframework.cache.caffeine.CaffeineCacheManager
import org.springframework.test.context.ActiveProfiles
import place.tomo.infra.config.CacheConfig

@SpringBootTest(classes = [CacheConfig::class])
@ActiveProfiles("test")
@DisplayName("CacheConfig")
class OIDCCacheConfigTest {
    @Autowired
    private lateinit var cacheManager: CacheManager

    @Test
    @DisplayName("CaffeineCacheManager가 올바르게 등록됨")
    fun `cacheManager when bean created expect caffeineCacheManager registered`() {
        assertThat(cacheManager).isInstanceOf(CaffeineCacheManager::class.java)
    }

    @Test
    @DisplayName("캐시 매니저가 null이 아님")
    fun `cacheManager when bean created expect not null`() {
        assertThat(cacheManager).isNotNull()
    }
}
