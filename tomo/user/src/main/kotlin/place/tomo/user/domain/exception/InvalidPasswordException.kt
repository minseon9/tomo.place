package place.tomo.user.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 유효하지 않은 비밀번호일 때 발생하는 예외
 */
class InvalidPasswordException(
    reason: String,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.BAD_REQUEST,
    errorCode = "INVALID_PASSWORD",
    message = "비밀번호가 유효하지 않습니다: {reason}",
    parameters = mapOf("reason" to reason),
    cause = cause,
)
