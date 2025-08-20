package place.tomo.user.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 유효하지 않은 사용자명일 때 발생하는 예외
 */
class InvalidUsernameException(
    username: String,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.BAD_REQUEST,
    errorCode = "INVALID_USERNAME",
    message = "사용자명은 필수이며 비어있을 수 없습니다: {username}",
    parameters = mapOf("username" to username),
    cause = cause,
)
