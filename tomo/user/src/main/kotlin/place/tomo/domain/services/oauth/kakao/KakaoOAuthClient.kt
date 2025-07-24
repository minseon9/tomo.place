package place.tomo.domain.services.oauth.kakao

import org.springframework.stereotype.Component
import place.tomo.common.http.HttpClient
import place.tomo.common.http.get
import place.tomo.common.http.post
import place.tomo.domain.constant.OAuthProvider
import place.tomo.domain.models.OAuthTokenResponse
import place.tomo.domain.models.OAuthUserInfo
import place.tomo.domain.services.oauth.OAuthClient

@Component
class KakaoOAuthClient(
    private val httpClient: HttpClient,
    private val oAuthProperties: KakaoOAuthProperties,
) : OAuthClient {
    override suspend fun getAccessToken(authorizationCode: String): OAuthTokenResponse {
        val response =
            httpClient.post<KakaoTokenResponse>(
                uri = oAuthProperties.tokenUri,
                body =
                    mapOf(
                        "grant_type" to "authorization_code",
                        "client_id" to oAuthProperties.clientId,
                        "client_secret" to oAuthProperties.clientSecret,
                        "code" to authorizationCode,
                        "redirect_uri" to oAuthProperties.redirectUri,
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
            httpClient.get<KakaoUserInfoResponse>(
                uri = oAuthProperties.userInfoUri,
                accessToken = accessToken,
            )

        return OAuthUserInfo(
            provider = OAuthProvider.KAKAO,
            socialId = response.id,
            email = response.kakao_account?.email,
            name = response.kakao_account?.profile?.nickname,
            profileImageUrl = response.kakao_account?.profile?.profile_image_url,
        )
    }

    private data class KakaoTokenResponse(
        val token_type: String,
        val access_token: String,
        val expires_in: Long,
        val refresh_token: String?,
        val refresh_token_expires_in: Long?,
        val scope: String?,
    )

    private data class KakaoUserInfoResponse(
        val id: String,
        val connected_at: String?,
        val kakao_account: KakaoAccount?,
    )

    private data class KakaoAccount(
        val profile_needs_agreement: Boolean?,
        val profile: Profile?,
        val email_needs_agreement: Boolean?,
        val is_email_valid: Boolean?,
        val is_email_verified: Boolean?,
        val email: String?,
    )

    private data class Profile(
        val nickname: String?,
        val thumbnail_image_url: String?,
        val profile_image_url: String?,
        val is_default_image: Boolean?,
    )
}
