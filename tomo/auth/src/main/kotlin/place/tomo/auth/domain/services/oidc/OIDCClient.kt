package place.tomo.auth.domain.services.oidc

import place.tomo.auth.domain.dtos.oidc.OIDCTokens
import place.tomo.common.http.HttpClient

interface OIDCClient {
    suspend fun getOIDCToken(authorizationCode: String): OIDCTokens
}

abstract class AbstractOIDCClient(
    protected val httpClient: HttpClient,
    protected val oidcProperties: OIDCProperties,
) : OIDCClient
