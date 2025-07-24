package place.tomo.domain.services.oauth.google

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component

@Component
@ConfigurationProperties(prefix = "oauth2.google")
data class GoogleOAuthProperties(
    var clientId: String = "",
    var clientSecret: String = "",
    var redirectUri: String = "",
    var tokenUri: String = "",
    var userInfoUri: String = "",
)
