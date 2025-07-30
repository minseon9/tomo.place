package place.tomo.domain.services.oauth.apple

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component

@Component
@ConfigurationProperties(prefix = "oauth2.apple")
data class AppleOAuthProperties(
    var clientId: String = "",
    var keyId: String = "", // JWT 발급 시 필요
    var teamId: String = "", // JWT 발급 시 필요
    var keyPath: String = "", // JWT 암호화 시 필요
    var redirectUri: String = "",
    var tokenUri: String = "https://appleid.apple.com/auth/token",
)
