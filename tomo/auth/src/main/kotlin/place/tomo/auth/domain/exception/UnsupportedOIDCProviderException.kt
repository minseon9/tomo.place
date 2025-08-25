package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

class UnsupportedOIDCProviderException(
    provider: String,
    cause: Throwable? = null,
) : BaseHttpException(
        status = HttpStatus.UNAUTHORIZED,
        errorCode = "AUTHENTICATION_FAILED",
        message = "지원하지 않는 제공자입니다: $provider",
        parameters = mapOf("provider" to provider),
        cause = cause,
    )
