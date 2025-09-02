package place.tomo.user.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

class DeactivatedUserException(
    email: String,
    cause: Throwable? = null,
) : BaseHttpException(
        status = HttpStatus.FORBIDDEN,
        errorCode = "DEACTIVATED_USER",
        message = "비활성화된 사용자입니다: {email}",
        parameters = mapOf("email" to email),
        cause = cause,
    )


