package place.tomo.domain.services.oauth

import org.springframework.stereotype.Component
import place.tomo.domain.constant.OAuthProvider
import place.tomo.domain.services.oauth.apple.AppleOAuthClient
import place.tomo.domain.services.oauth.google.GoogleOAuthClient
import place.tomo.domain.services.oauth.kakao.KakaoOAuthClient

@Component
class OAuthClientFactory(
    private val googleOAuthClient: GoogleOAuthClient,
    private val kakaoOAuthClient: KakaoOAuthClient,
    private val appleOAuthClient: AppleOAuthClient,
) {
    fun getClient(provider: OAuthProvider): OAuthClient =
        when (provider) {
            OAuthProvider.GOOGLE -> googleOAuthClient
            OAuthProvider.KAKAO -> kakaoOAuthClient
            OAuthProvider.APPLE -> appleOAuthClient
        }
}
