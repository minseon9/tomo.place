package place.tomo.domain.services.oauth.apple

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component

@Component
@ConfigurationProperties(prefix = "oauth2.apple")
data class AppleOAuthProperties(
    var clientId: String = "",
    var keyId: String = "",
    var teamId: String = "",
    var keyPath: String = "",
    var redirectUri: String = "",
    var tokenUri: String = "https://appleid.apple.com/auth/token",
    var userInfoUri: String = "https://appleid.apple.com/auth/userinfo",
)
