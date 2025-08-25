package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException
import place.tomo.contract.constant.OIDCProviderType

/**
 * 소셜 계정이 연결되지 않았을 때 발생하는 예외
 */
class SocialAccountNotLinkedException(
    provider: OIDCProviderType,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.UNAUTHORIZED,
    errorCode = "SOCIAL_ACCOUNT_NOT_LINKED",
    message = "해당 {provider} 계정이 비활성화되었거나 없습니다",
    parameters = mapOf("provider" to provider.name),
    cause = cause,
)
