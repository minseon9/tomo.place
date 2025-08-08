package place.tomo.auth.domain.models

import place.tomo.contract.constant.OIDCProviderType

data class OidcUserInfo(
    val provider: OIDCProviderType,
    val socialId: String,
    val email: String?,
    val name: String?,
    val profileImageUrl: String?,
)
