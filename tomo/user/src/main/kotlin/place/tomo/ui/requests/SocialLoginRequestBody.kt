package place.tomo.ui.requests

import place.tomo.domain.constant.OAuthProvider

data class SocialLoginRequestBody(
    val provider: OAuthProvider,
    val authorizationCode: String,
)
