package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 유효하지 않은 ID 토큰일 때 발생하는 예외
 */
class InvalidIdTokenException(
    reason: String,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.UNAUTHORIZED,
    errorCode = "INVALID_ID_TOKEN",
    message = "유효하지 않은 ID 토큰입니다: {reason}",
    parameters = mapOf("reason" to reason),
    cause = cause,
)
