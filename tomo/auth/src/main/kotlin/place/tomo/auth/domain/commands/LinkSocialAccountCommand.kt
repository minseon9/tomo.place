package place.tomo.auth.domain.commands

import place.tomo.contract.constant.OIDCProviderType
import place.tomo.contract.dtos.UserInfoDTO

data class LinkSocialAccountCommand(
    val user: UserInfoDTO,
    val provider: OIDCProviderType,
    val socialId: String,
    val email: String,
    val name: String?,
    val profileImageUrl: String?,
)
