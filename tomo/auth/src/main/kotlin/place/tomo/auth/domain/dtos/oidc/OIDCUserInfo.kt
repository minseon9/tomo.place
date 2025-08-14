package place.tomo.auth.domain.dtos.oidc

import place.tomo.contract.constant.OIDCProviderType

data class OIDCUserInfo(
    val provider: OIDCProviderType,
    val socialId: String,
    val email: String,
    val name: String,
    val profileImageUrl: String?,
)
