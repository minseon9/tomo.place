package place.tomo.domain.commands

import place.tomo.domain.constant.OAuthProvider


data class LinkSocialAccountCommand(
    val provider: OAuthProvider,
    val socialId: String,
    val email: String?,
    val name: String?,
    val profileImageUrl: String?
) 
