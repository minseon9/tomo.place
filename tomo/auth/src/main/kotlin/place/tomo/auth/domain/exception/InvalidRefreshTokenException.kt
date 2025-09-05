package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * Refresh Token이 유효하지 않을 때 발생하는 예외
 */
class InvalidRefreshTokenException(
    reason: String,
    cause: Throwable? = null,
) : BaseHttpException(
        status = HttpStatus.UNAUTHORIZED,
        errorCode = "INVALID_REFRESH_TOKEN",
        message = "유효하지 않은 토큰입니다: {reason}",
        parameters = mapOf("reason" to reason),
        cause = cause,
    )
