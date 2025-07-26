package place.tomo.domain.services.oauth

import place.tomo.domain.models.OAuthTokenResponse
import place.tomo.domain.models.OAuthUserInfo

interface OAuthClient {
    suspend fun getAccessToken(authorizationCode: String): OAuthTokenResponse

    // FIXME: abstract class에서 private 을 구현하도록 수정할 수 있을 것?
    suspend fun getUserInfo(accessToken: String): OAuthUserInfo
}
