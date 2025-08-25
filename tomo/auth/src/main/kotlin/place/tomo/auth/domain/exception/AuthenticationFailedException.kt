package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 인증에 실패했을 때 발생하는 예외
 */
class AuthenticationFailedException(
    reason: String = "이메일 또는 비밀번호가 올바르지 않습니다",
    cause: Throwable? = null,
) : BaseHttpException(
        status = HttpStatus.UNAUTHORIZED,
        errorCode = "AUTHENTICATION_FAILED",
        message = "인증에 실패했습니다: {reason}",
        parameters = mapOf("reason" to reason),
        cause = cause,
    )
