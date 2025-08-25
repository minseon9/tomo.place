package place.tomo.user.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 유효하지 않은 이메일 형식일 때 발생하는 예외
 */
class InvalidEmailException(
    email: String,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.BAD_REQUEST,
    errorCode = "INVALID_EMAIL",
    message = "이메일 형식이 올바르지 않습니다: {email}",
    parameters = mapOf("email" to email),
    cause = cause,
)
