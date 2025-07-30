package place.tomo.domain.services.oauth.google

import org.springframework.stereotype.Component
import place.tomo.common.http.HttpClient
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

    override suspend fun getUserInfo(id_token: String): OAuthUserInfo {
        // FIXME: parsing id token
//        {
//            "iss": "https://accounts.google.com",
//            "azp": "1234987819200.apps.googleusercontent.com",
//            "aud": "1234987819200.apps.googleusercontent.com",
//            "sub": "10769150350006150715113082367",
//            "at_hash": "HK6E_P6Dh8Y93mRNtsDB1Q",
//            "hd": "example.com",
//            "email": "jsmith@example.com",
//            "email_verified": "true",
//            "iat": 1353601026,
//            "exp": 1353604926,
//            "nonce": "0394852-3190485-2490358"
//            "picture": profile image url
//        }
        return OAuthUserInfo(
            provider = OAuthProvider.GOOGLE,
            socialId = response.sub,
            email = response.email,
            name = response.name,
            profileImageUrl = response.picture,
        )
    }

//    access_token 	Google API로 전송할 수 있는 토큰입니다.
//    expires_in 	액세스 토큰의 남은 전체 기간(초)입니다.
//    id_token 	Google에서 디지털 서명한 사용자의 ID 정보가 포함된 JWT입니다.
//    scope 	access_token에서 부여한 액세스 범위로, 공백으로 구분되고 대소문자가 구분되는 문자열 목록으로 표현됩니다.
//    token_type 	반환된 토큰의 유형을 식별합니다. 이때 이 필드의 값은 항상 Bearer입니다.
//    refresh_token
    private data class GoogleTokenResponse(
        val access_token: String,
        val expires_in: Long,
        val id_token: Long,
        val scope: String,
        val token_type: String,
        val refresh_token: String?,
    )
}
