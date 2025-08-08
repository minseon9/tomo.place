package place.tomo.auth.domain.commands

import place.tomo.contract.constant.OIDCProviderType

data class LinkSocialAccountCommand(
    val provider: OIDCProviderType,
    val socialId: String,
    val email: String?,
    val name: String?,
    val profileImageUrl: String?,
)
