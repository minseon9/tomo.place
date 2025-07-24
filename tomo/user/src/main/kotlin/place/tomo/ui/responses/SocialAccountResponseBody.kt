package place.tomo.ui.responses

import place.tomo.domain.constant.OAuthProvider

data class SocialAccountResponseBody(
    val provider: OAuthProvider,
    val email: String?,
    val name: String?,
    val profileImageUrl: String?,
    val isActive: Boolean
)

data class LinkedSocialAccountsResponseBody(
    val accounts: List<SocialAccountResponseBody>
) 