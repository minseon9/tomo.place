package place.tomo.auth.domain.services.oidc.google

import org.springframework.boot.context.properties.ConfigurationProperties
import place.tomo.auth.domain.services.oidc.OIDCProperties

@ConfigurationProperties(prefix = "spring.security.oauth2.client.registration.google")
data class GoogleOIDCProperties(
    override val clientId: String = "",
    override val clientSecret: String = "",
    override val redirectUri: String = "",
) : OIDCProperties
