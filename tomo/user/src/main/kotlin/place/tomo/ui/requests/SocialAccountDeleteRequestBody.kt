package place.tomo.ui.requests

// FIXME: domain layer constant
import place.tomo.domain.constant.OAuthProvider

data class SocialAccountDeleteRequestBody(
    val provider: OAuthProvider,
)
