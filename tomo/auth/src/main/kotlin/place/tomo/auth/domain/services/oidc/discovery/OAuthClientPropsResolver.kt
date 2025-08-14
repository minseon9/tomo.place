package place.tomo.auth.domain.services.oidc.discovery

import org.springframework.boot.autoconfigure.security.oauth2.client.OAuth2ClientProperties
import org.springframework.stereotype.Component
import place.tomo.contract.constant.OIDCProviderType

@Component
class OAuthClientPropsResolver(
    private val properties: OAuth2ClientProperties,
) {
    fun getIssuer(provider: OIDCProviderType): String? = properties.provider[provider.name.lowercase()]?.issuerUri
}
