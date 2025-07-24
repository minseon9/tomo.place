package place.tomo.domain.models

import place.tomo.domain.constant.OAuthProvider

data class OAuthUserInfo(
    val provider: OAuthProvider,
    val socialId: String,
    val email: String?,
    val name: String?,
    val profileImageUrl: String?
)

data class OAuthTokenResponse(
    val accessToken: String,
    val refreshToken: String?,
    val expiresIn: Long?
) 