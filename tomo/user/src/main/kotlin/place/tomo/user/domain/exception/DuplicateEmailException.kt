package place.tomo.user.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 중복된 이메일로 사용자 생성 시 발생하는 예외
 */
class DuplicateEmailException(
    email: String,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.CONFLICT,
    errorCode = "DUPLICATE_EMAIL",
    message = "이미 존재하는 이메일입니다: {email}",
    parameters = mapOf("email" to email),
    cause = cause,
)
