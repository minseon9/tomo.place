package place.tomo.domain.services.oauth

import place.tomo.domain.models.OAuthTokenResponse
import place.tomo.domain.models.OAuthUserInfo

interface OAuthClient {
    suspend fun getAccessToken(authorizationCode: String): OAuthTokenResponse

    suspend fun getUserInfo(accessToken: String): OAuthUserInfo
}
