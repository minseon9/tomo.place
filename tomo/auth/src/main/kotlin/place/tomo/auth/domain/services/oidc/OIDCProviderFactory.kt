package place.tomo.auth.domain.services.oidc

import org.springframework.stereotype.Component
import place.tomo.auth.domain.exception.UnsupportedOIDCProviderException
import place.tomo.auth.domain.services.oidc.google.GoogleOIDCProvider
import place.tomo.contract.constant.OIDCProviderType

@Component
class OIDCProviderFactory(
    private val googleOIDCProvider: GoogleOIDCProvider,
) {
    fun getService(provider: OIDCProviderType): OIDCProvider =
        when (provider) {
            OIDCProviderType.GOOGLE -> googleOIDCProvider
            else -> throw UnsupportedOIDCProviderException(provider.name)
        }
}
