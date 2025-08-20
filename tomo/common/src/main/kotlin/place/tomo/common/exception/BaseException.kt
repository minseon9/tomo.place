package place.tomo.common.exception

import org.springframework.http.HttpStatus
import java.time.LocalDateTime

interface BaseException {
    val status: HttpStatus
    val errorCode: String
    val message: String
    val parameters: Map<String, Any>
    val cause: Throwable?
    val timestamp: LocalDateTime

    fun getFormattedMessage(): String =
        if (parameters.isEmpty()) {
            message
        } else {
            parameters.entries.fold(message) { template, (key, value) ->
                template.replace("{$key}", value.toString())
            }
        }
}

abstract class BaseHttpException(
    override val status: HttpStatus,
    override val errorCode: String,
    override val message: String,
    override val parameters: Map<String, Any> = emptyMap(),
    override val cause: Throwable? = null,
    override val timestamp: LocalDateTime = LocalDateTime.now(),
) : RuntimeException(message, cause),
    BaseException {
    override fun toString(): String = "${this::class.simpleName}(errorCode=$errorCode, message=${getFormattedMessage()})"
}
