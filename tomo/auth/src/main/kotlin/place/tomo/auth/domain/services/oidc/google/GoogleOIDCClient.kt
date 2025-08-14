package place.tomo.auth.domain.services.oidc.google

import org.springframework.stereotype.Component
import place.tomo.auth.domain.dtos.oidc.OIDCTokens
import place.tomo.auth.domain.services.oidc.AbstractOIDCClient
import place.tomo.auth.domain.services.oidc.OIDCProperties
import place.tomo.auth.domain.services.oidc.discovery.OIDCEndpointResolver
import place.tomo.common.http.HttpClient
import place.tomo.common.http.post
import place.tomo.contract.constant.OIDCProviderType

@Component
class GoogleOIDCClient(
    httpClient: HttpClient,
    oidcProperties: OIDCProperties,
    private val endpointResolver: OIDCEndpointResolver,
) : AbstractOIDCClient(httpClient, oidcProperties) {
    override suspend fun getOIDCToken(authorizationCode: String): OIDCTokens {
        val endpoints = endpointResolver.resolve(OIDCProviderType.GOOGLE)
        val response =
            httpClient.post<GoogleTokenResponse>(
                uri = endpoints.tokenEndpoint,
                query =
                    mapOf(
                        "code" to authorizationCode,
                        "client_id" to oidcProperties.clientId,
                        "client_secret" to oidcProperties.clientSecret,
                        "redirect_uri" to oidcProperties.redirectUri,
                        "grant_type" to "authorization_code",
                        "access_type" to "offline",
                    ),
            )

        return OIDCTokens(
            accessToken = response.access_token,
            refreshToken = response.refresh_token,
            idToken = response.id_token,
            expiresIn = response.expires_in,
        )
    }

    private data class GoogleTokenResponse(
        val access_token: String,
        val expires_in: Long,
        val refresh_token: String?,
        val scope: String,
        val token_type: String,
        val id_token: String,
    )
}
