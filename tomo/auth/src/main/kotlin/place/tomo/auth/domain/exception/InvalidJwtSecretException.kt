package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

class InvalidJwtSecretException(
    cause: Throwable? = null,
) : BaseHttpException(
        status = HttpStatus.BAD_REQUEST,
        errorCode = "INVALID_JWT_SECRET",
        message = "유효하지 않은 jwt key입니다.",
        cause = cause,
    )
