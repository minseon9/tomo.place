package place.tomo.domain.services.oauth.google

import org.springframework.stereotype.Component
import place.tomo.common.http.HttpClient
import place.tomo.common.http.get
import place.tomo.common.http.post
import place.tomo.domain.constant.OAuthProvider
import place.tomo.domain.models.OAuthTokenResponse
import place.tomo.domain.models.OAuthUserInfo
import place.tomo.domain.services.oauth.OAuthClient

@Component
class GoogleOAuthClient(
    private val httpClient: HttpClient,
    private val oAuthProperties: GoogleOAuthProperties,
) : OAuthClient {
    override suspend fun getAccessToken(authorizationCode: String): OAuthTokenResponse {
        val response =
            httpClient.post<GoogleTokenResponse>(
                uri = oAuthProperties.tokenUri,
                body =
                    mapOf(
                        "code" to authorizationCode,
                        "client_id" to oAuthProperties.clientId,
                        "client_secret" to oAuthProperties.clientSecret,
                        "redirect_uri" to oAuthProperties.redirectUri,
                        "grant_type" to "authorization_code",
                    ),
            )

        return OAuthTokenResponse(
            accessToken = response.access_token,
            refreshToken = response.refresh_token,
            expiresIn = response.expires_in,
        )
    }

    override suspend fun getUserInfo(accessToken: String): OAuthUserInfo {
        val response =
            httpClient.get<GoogleUserInfoResponse>(
                uri = oAuthProperties.userInfoUri,
                accessToken = accessToken,
            )

        return OAuthUserInfo(
            provider = OAuthProvider.GOOGLE,
            socialId = response.sub,
            email = response.email,
            name = response.name,
            profileImageUrl = response.picture,
        )
    }

    private data class GoogleTokenResponse(
        val access_token: String,
        val expires_in: Long,
        val refresh_token: String?,
        val scope: String,
        val token_type: String,
    )

    private data class GoogleUserInfoResponse(
        val sub: String,
        val name: String?,
        val given_name: String?,
        val family_name: String?,
        val picture: String?,
        val email: String?,
        val email_verified: Boolean?,
        val locale: String?,
    )
}
