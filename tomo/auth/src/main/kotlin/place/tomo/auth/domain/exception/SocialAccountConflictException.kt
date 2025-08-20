package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 소셜 계정 충돌 예외
 */
class SocialAccountConflictException(
    provider: String,
) : BaseHttpException(
    status = HttpStatus.CONFLICT,
    errorCode = "SOCIAL_ACCOUNT_CONFLICT",
    message = "해당 {provider} 계정은 이미 다른 회원과 연결되어 있습니다.",
    parameters = mapOf("provider" to provider),
)
