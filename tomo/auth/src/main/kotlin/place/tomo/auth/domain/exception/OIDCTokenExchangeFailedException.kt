package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * OIDC 토큰 교환에 실패했을 때 발생하는 예외
 */
class OIDCTokenExchangeFailedException(
    reason: String,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.UNAUTHORIZED,
    errorCode = "OIDC_TOKEN_EXCHANGE_FAILED",
    message = "OIDC 토큰 교환에 실패했습니다: {reason}",
    parameters = mapOf("reason" to reason),
    cause = cause,
)
