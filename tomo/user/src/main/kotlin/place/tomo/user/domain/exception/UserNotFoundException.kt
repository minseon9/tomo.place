package place.tomo.user.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 사용자를 찾을 수 없을 때 발생하는 예외
 */
class UserNotFoundException(
    userId: Long,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.NOT_FOUND,
    errorCode = "USER_NOT_FOUND",
    message = "사용자를 찾을 수 없습니다: {userId}",
    parameters = mapOf("userId" to userId),
    cause = cause,
)
