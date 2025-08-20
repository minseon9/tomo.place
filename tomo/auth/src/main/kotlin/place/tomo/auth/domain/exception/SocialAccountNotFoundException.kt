package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 소셜 계정을 찾을 수 없는 예외
 */
class SocialAccountNotFoundException(
    provider: String,
) : BaseHttpException(
    status = HttpStatus.NOT_FOUND,
    errorCode = "SOCIAL_ACCOUNT_NOT_FOUND",
    message = "연결된 {provider} 계정을 찾을 수 없습니다.",
    parameters = mapOf("provider" to provider),
)
