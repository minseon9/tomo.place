package place.tomo.common.exception

import jakarta.servlet.http.HttpServletRequest
import jakarta.validation.ConstraintViolationException
import org.slf4j.LoggerFactory
import org.slf4j.MDC
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.http.converter.HttpMessageNotReadableException
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.core.AuthenticationException
import org.springframework.web.HttpRequestMethodNotSupportedException
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.MissingServletRequestParameterException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException
import org.springframework.web.servlet.NoHandlerFoundException
import java.time.LocalDateTime
import java.util.UUID
import org.hibernate.exception.ConstraintViolationException as HibernateConstraintViolationException

@RestControllerAdvice
class GlobalExceptionHandler {
    private val logger = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)

    @ExceptionHandler(BaseHttpException::class)
    fun handleBaseException(
        ex: BaseHttpException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)
        val errorResponse =
            ErrorResponse(
                timestamp = ex.timestamp,
                status = ex.status.value(),
                error = ex.status.reasonPhrase,
                errorCode = ex.errorCode,
                message = ex.getFormattedMessage(),
                path = request.requestURI,
                traceId = getTraceId(),
            )
        return ResponseEntity.status(ex.status).body(errorResponse)
    }

    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidation(
        ex: MethodArgumentNotValidException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.BAD_REQUEST.value(),
                error = HttpStatus.BAD_REQUEST.reasonPhrase,
                errorCode = "VALIDATION_ERROR",
                message = "유효성 검사에 실패했습니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.badRequest().body(errorResponse)
    }

    @ExceptionHandler(ConstraintViolationException::class)
    fun handleConstraintViolation(
        ex: ConstraintViolationException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.BAD_REQUEST.value(),
                error = HttpStatus.BAD_REQUEST.reasonPhrase,
                errorCode = "VALIDATION_ERROR",
                message = "제약 조건 검증에 실패했습니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.badRequest().body(errorResponse)
    }

    @ExceptionHandler(HibernateConstraintViolationException::class)
    fun handleDbConstraintViolation(
        ex: HibernateConstraintViolationException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.CONFLICT.value(),
                error = HttpStatus.CONFLICT.reasonPhrase,
                errorCode = "DB_CONSTRAINT_VIOLATION",
                message = "데이터베이스 제약 조건 위반",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.status(HttpStatus.CONFLICT).body(errorResponse)
    }

    @ExceptionHandler(MissingServletRequestParameterException::class)
    fun handleMissingParam(
        ex: MissingServletRequestParameterException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.BAD_REQUEST.value(),
                error = HttpStatus.BAD_REQUEST.reasonPhrase,
                errorCode = "MISSING_PARAMETER",
                message = "필수 파라미터 '${ex.parameterName}'이 누락되었습니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.badRequest().body(errorResponse)
    }

    @ExceptionHandler(HttpMessageNotReadableException::class)
    fun handleNotReadable(
        ex: HttpMessageNotReadableException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.BAD_REQUEST.value(),
                error = HttpStatus.BAD_REQUEST.reasonPhrase,
                errorCode = "MALFORMED_JSON",
                message = "잘못된 JSON 요청입니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.badRequest().body(errorResponse)
    }

    @ExceptionHandler(AuthenticationException::class)
    fun handleAuthentication(
        ex: AuthenticationException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.UNAUTHORIZED.value(),
                error = HttpStatus.UNAUTHORIZED.reasonPhrase,
                errorCode = "AUTHENTICATION_FAILED",
                message = ex.message ?: "인증에 실패했습니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse)
    }

    @ExceptionHandler(AccessDeniedException::class)
    fun handleAccessDenied(
        ex: AccessDeniedException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.FORBIDDEN.value(),
                error = HttpStatus.FORBIDDEN.reasonPhrase,
                errorCode = "ACCESS_DENIED",
                message = ex.message ?: "접근이 거부되었습니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(errorResponse)
    }

    @ExceptionHandler(IllegalArgumentException::class)
    fun handleBadRequest(
        ex: IllegalArgumentException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.BAD_REQUEST.value(),
                error = HttpStatus.BAD_REQUEST.reasonPhrase,
                errorCode = "INVALID_ARGUMENT",
                message = ex.message ?: "잘못된 인수입니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.badRequest().body(errorResponse)
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException::class)
    fun handleTypeMismatch(
        ex: MethodArgumentTypeMismatchException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.BAD_REQUEST.value(),
                error = HttpStatus.BAD_REQUEST.reasonPhrase,
                errorCode = "TYPE_MISMATCH",
                message = "파라미터 '${ex.name}'은 ${ex.requiredType?.simpleName} 타입이어야 합니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.badRequest().body(errorResponse)
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException::class)
    fun handleMethodNotSupported(
        ex: HttpRequestMethodNotSupportedException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.METHOD_NOT_ALLOWED.value(),
                error = HttpStatus.METHOD_NOT_ALLOWED.reasonPhrase,
                errorCode = "METHOD_NOT_ALLOWED",
                message = "지원하지 않는 HTTP 메서드 '${ex.method}'입니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED).body(errorResponse)
    }

    @ExceptionHandler(NoHandlerFoundException::class)
    fun handleNoHandlerFound(
        ex: NoHandlerFoundException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.NOT_FOUND.value(),
                error = HttpStatus.NOT_FOUND.reasonPhrase,
                errorCode = "NO_HANDLER_FOUND",
                message = "요청한 리소스를 찾을 수 없습니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse)
    }

    @ExceptionHandler(Exception::class)
    fun handleGeneric(
        ex: Exception,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        logException(ex, request)

        val errorResponse =
            ErrorResponse(
                timestamp = LocalDateTime.now(),
                status = HttpStatus.INTERNAL_SERVER_ERROR.value(),
                error = HttpStatus.INTERNAL_SERVER_ERROR.reasonPhrase,
                errorCode = "INTERNAL_SERVER_ERROR",
                message = "내부 서버 오류가 발생했습니다",
                path = request.requestURI,
                traceId = getTraceId(),
            )

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse)
    }

    private fun logException(
        ex: Throwable,
        request: HttpServletRequest,
    ) {
        val logMessage =
            buildString {
                append("Exception occurred: ${ex.javaClass.simpleName}")
                append(" | Path: ${request.requestURI}")
                append(" | Method: ${request.method}")
                append(" | User-Agent: ${request.getHeader("User-Agent")}")
                append(" | Remote Address: ${request.remoteAddr}")
                append(" | Message: ${ex.message}")
            }

        when (ex) {
            is BaseHttpException -> logger.warn(logMessage)
            is IllegalArgumentException,
            is MissingServletRequestParameterException,
            is HttpMessageNotReadableException,
            is MethodArgumentNotValidException,
            is ConstraintViolationException,
            -> logger.warn(logMessage)
            else -> logger.error(logMessage, ex)
        }
    }

    private fun getTraceId(): String = MDC.get("traceId") ?: UUID.randomUUID().toString().substring(0, 8)
}
