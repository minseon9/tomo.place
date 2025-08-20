package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 이메일로 사용자를 찾을 수 없을 때 발생하는 예외
 */
class UserNotFoundByEmailException(
    email: String,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.UNAUTHORIZED,
    errorCode = "USER_NOT_FOUND_BY_EMAIL",
    message = "회원을 찾을 수 없습니다: {email}",
    parameters = mapOf("email" to email),
    cause = cause,
)
