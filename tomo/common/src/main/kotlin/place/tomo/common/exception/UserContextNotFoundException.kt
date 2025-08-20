package place.tomo.common.exception

import org.springframework.http.HttpStatus

class UserContextNotFoundException(
    email: String,
    cause: Throwable? = null,
) : BaseHttpException(
        status = HttpStatus.UNAUTHORIZED,
        errorCode = "USER_CONTEXT_ERROR",
        message = "인증된 사용자를 찾을 수 없습니다: {email}",
        parameters = mapOf("email" to email),
        cause = cause,
    )
