package place.tomo.common.exception

import org.springframework.http.HttpStatus

class NotFoundActiveUserException(
    email: String,
    cause: Throwable? = null,
) : BaseHttpException(
        status = HttpStatus.UNAUTHORIZED,
        errorCode = "ACTIVE_USER_NOT_FOUND",
        message = "사용자를 찾을 수 없습니다: {email}",
        parameters = mapOf("email" to email),
        cause = cause,
    )
