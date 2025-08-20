package place.tomo.auth.domain.services.oidc

import place.tomo.auth.domain.dtos.oidc.OIDCTokens
import place.tomo.auth.domain.exception.OIDCTokenExchangeFailedException
import place.tomo.common.http.HttpClient

interface OIDCClient {
    suspend fun getOIDCToken(authorizationCode: String): OIDCTokens
}

abstract class AbstractOIDCClient(
    protected val httpClient: HttpClient,
    protected val oidcProperties: OIDCProperties,
) : OIDCClient {
    override suspend fun getOIDCToken(authorizationCode: String): OIDCTokens {
        try {
            return doGetOIDCToken(authorizationCode)
        } catch (e: Exception) {
            throw OIDCTokenExchangeFailedException(e.message ?: "알 수 없는 오류", e)
        }
    }

    protected abstract suspend fun doGetOIDCToken(authorizationCode: String): OIDCTokens
}
