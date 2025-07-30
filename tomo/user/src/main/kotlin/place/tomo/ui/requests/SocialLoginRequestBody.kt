package place.tomo.ui.requests

import place.tomo.domain.constant.OAuthProvider

// FIXME: state ( CSRF token)
data class SocialLoginRequestBody(
    val provider: OAuthProvider,
    val authorizationCode: String,
)
