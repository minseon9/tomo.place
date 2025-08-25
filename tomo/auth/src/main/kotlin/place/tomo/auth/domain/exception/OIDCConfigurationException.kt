package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * OIDC 설정 관련 예외
 */
class OIDCConfigurationException(
    reason: String,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.INTERNAL_SERVER_ERROR,
    errorCode = "OIDC_CONFIGURATION_ERROR",
    message = "OIDC 설정 오류: {reason}",
    parameters = mapOf("reason" to reason),
    cause = cause,
)
