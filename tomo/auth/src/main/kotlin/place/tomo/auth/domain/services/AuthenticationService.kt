package place.tomo.auth.domain.services

import kotlinx.coroutines.runBlocking
import org.springframework.stereotype.Service
import place.tomo.auth.domain.dtos.oidc.OIDCUserInfo
import place.tomo.auth.domain.services.oidc.OIDCProviderFactory
import place.tomo.contract.constant.OIDCProviderType

@Service
class AuthenticationService(
    private val oAuthServiceFactory: OIDCProviderFactory,
) {
    fun getOidcUserInfo(
        provider: OIDCProviderType,
        authorizationCode: String,
    ): OIDCUserInfo =
        runBlocking {
            val service = oAuthServiceFactory.getService(provider)
            service.getOIDCUserInfo(authorizationCode)
        }
}
