package place.tomo.domain.services.oauth.google

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component

// FIXME: OIDC 로 일괄 변경 필요
@Component
@ConfigurationProperties(prefix = "oauth2.google")
data class GoogleOAuthProperties(
    var clientId: String = "",
    var clientSecret: String = "",
    var redirectUri: String = "",
    var tokenUri: String = "", // FIXME: naming
    var userInfoUri: String = "", // FIXME: OIDC로 변경으로 제거
)
