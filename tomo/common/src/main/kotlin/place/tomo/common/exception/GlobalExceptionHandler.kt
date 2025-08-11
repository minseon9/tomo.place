package place.tomo.common.exception

import org.springframework.http.ResponseEntity
import org.springframework.http.converter.HttpMessageNotReadableException
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.core.AuthenticationException
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.MissingServletRequestParameterException
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler
import jakarta.validation.ConstraintViolationException as JakartaConstraintViolationException
import org.hibernate.exception.ConstraintViolationException as HibernateConstraintViolationException

@ControllerAdvice
class GlobalExceptionHandler {
    data class ErrorResponse(
        val status: Int,
        val message: String,
        val errorCode: String? = null,
    )

    @ExceptionHandler(HttpException::class)
    fun handleHttpException(ex: HttpException): ResponseEntity<ErrorResponse> =
        ResponseEntity
            .status(ex.status.code)
            .body(ErrorResponse(status = ex.status.code, message = ex.message, errorCode = ex.errorCode))

    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidation(ex: MethodArgumentNotValidException): ResponseEntity<ErrorResponse> {
        val message =
            ex.bindingResult.fieldErrors
                .joinToString(
                    separator = ", ",
                    transform = { "${it.field}: ${it.defaultMessage}" },
                ).ifBlank { ex.message ?: "Validation failed" }

        return ResponseEntity
            .status(HttpErrorStatus.BAD_REQUEST.code)
            .body(ErrorResponse(status = HttpErrorStatus.BAD_REQUEST.code, message = message))
    }

    @ExceptionHandler(JakartaConstraintViolationException::class)
    fun handleConstraintViolation(ex: JakartaConstraintViolationException): ResponseEntity<ErrorResponse> =
        ResponseEntity
            .status(HttpErrorStatus.BAD_REQUEST.code)
            .body(
                ErrorResponse(
                    status = HttpErrorStatus.BAD_REQUEST.code,
                    message =
                        ex.constraintViolations.joinToString(
                            ", ",
                            transform = { "${it.propertyPath}: ${it.message}" },
                        ),
                ),
            )

    @ExceptionHandler(HibernateConstraintViolationException::class)
    fun handleDbConstraintViolation(ex: HibernateConstraintViolationException): ResponseEntity<ErrorResponse> =
        ResponseEntity
            .status(HttpErrorStatus.CONFLICT.code)
            .body(
                ErrorResponse(
                    status = HttpErrorStatus.CONFLICT.code,
                    message = ex.sqlException?.message ?: ex.message ?: "Constraint violation",
                ),
            )

    @ExceptionHandler(MissingServletRequestParameterException::class)
    fun handleMissingParam(ex: MissingServletRequestParameterException): ResponseEntity<ErrorResponse> =
        ResponseEntity
            .status(HttpErrorStatus.BAD_REQUEST.code)
            .body(ErrorResponse(status = HttpErrorStatus.BAD_REQUEST.code, message = ex.message ?: "Bad request"))

    @ExceptionHandler(HttpMessageNotReadableException::class)
    fun handleNotReadable(ex: HttpMessageNotReadableException): ResponseEntity<ErrorResponse> =
        ResponseEntity
            .status(HttpErrorStatus.BAD_REQUEST.code)
            .body(ErrorResponse(status = HttpErrorStatus.BAD_REQUEST.code, message = ex.message ?: "Malformed JSON"))

    @ExceptionHandler(AuthenticationException::class)
    fun handleAuthentication(ex: AuthenticationException): ResponseEntity<ErrorResponse> =
        ResponseEntity
            .status(HttpErrorStatus.UNAUTHORIZED.code)
            .body(ErrorResponse(status = HttpErrorStatus.UNAUTHORIZED.code, message = ex.message ?: "Unauthorized"))

    @ExceptionHandler(AccessDeniedException::class)
    fun handleAccessDenied(ex: AccessDeniedException): ResponseEntity<ErrorResponse> =
        ResponseEntity
            .status(HttpErrorStatus.FORBIDDEN.code)
            .body(ErrorResponse(status = HttpErrorStatus.FORBIDDEN.code, message = ex.message ?: "Forbidden"))

    @ExceptionHandler(IllegalArgumentException::class)
    fun handleBadRequest(ex: IllegalArgumentException): ResponseEntity<ErrorResponse> =
        ResponseEntity
            .badRequest()
            .body(ErrorResponse(status = HttpErrorStatus.BAD_REQUEST.code, message = ex.message ?: "Bad request"))

    @ExceptionHandler(Exception::class)
    fun handleGeneric(ex: Exception): ResponseEntity<ErrorResponse> =
        ResponseEntity
            .status(HttpErrorStatus.INTERNAL_SERVER_ERROR.code)
            .body(ErrorResponse(status = HttpErrorStatus.INTERNAL_SERVER_ERROR.code, message = ex.message ?: "Server error"))
}
