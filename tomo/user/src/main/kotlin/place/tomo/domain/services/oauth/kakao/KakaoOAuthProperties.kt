package place.tomo.domain.services.oauth.kakao

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component

@Component
@ConfigurationProperties(prefix = "oauth2.kakao")
data class KakaoOAuthProperties(
    var clientId: String = "",
    var clientSecret: String = "",
    var redirectUri: String = "",
    var tokenUri: String = "",
    var userInfoUri: String = "",
)
