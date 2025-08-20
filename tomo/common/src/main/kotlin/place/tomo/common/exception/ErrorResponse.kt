package place.tomo.common.exception

import com.fasterxml.jackson.annotation.JsonInclude
import java.time.LocalDateTime

@JsonInclude(JsonInclude.Include.NON_NULL)
data class ErrorResponse(
    val timestamp: LocalDateTime,
    val status: Int,
    val error: String,
    val errorCode: String?,
    val message: String,
    val path: String? = null,
    val traceId: String? = null,
)
