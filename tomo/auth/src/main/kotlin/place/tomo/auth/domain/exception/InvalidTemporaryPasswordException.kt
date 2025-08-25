package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 임시 비밀번호가 유효하지 않을 때 발생하는 예외
 */
class InvalidTemporaryPasswordException(
    reason: String,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.BAD_REQUEST,
    errorCode = "INVALID_TEMPORARY_PASSWORD",
    message = "임시 비밀번호가 유효하지 않습니다: {reason}",
    parameters = mapOf("reason" to reason),
    cause = cause,
)
