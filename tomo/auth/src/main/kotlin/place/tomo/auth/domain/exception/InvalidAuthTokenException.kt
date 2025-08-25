package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

class InvalidAuthTokenException(
    cause: Throwable? = null,
) : BaseHttpException(
        status = HttpStatus.UNAUTHORIZED,
        errorCode = "INVALID_AUTH_TOKEN",
        message = "유효하지 않은 인증 토큰입니다.",
        cause = cause,
    )
