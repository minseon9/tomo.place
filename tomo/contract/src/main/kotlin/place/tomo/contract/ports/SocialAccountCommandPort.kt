package place.tomo.contract.ports

import place.tomo.contract.constant.OIDCProviderType
import place.tomo.contract.vo.UserId

interface SocialAccountCommandPort {
    fun link(userId: UserId, provider: OIDCProviderType, subject: String, email: String?, name: String?, profileImageUrl: String?)
    fun softDeleteByUserId(userId: UserId)
}


