package place.tomo.common.exception

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import java.time.LocalDateTime

@DisplayName("ErrorResponse")
class ErrorResponseTest {
    @Nested
    @DisplayName("ErrorResponse 생성")
    inner class ErrorResponseCreation {
        @Test
        @DisplayName("필수 필드로 ErrorResponse를 생성할 때 모든 속성이 올바르게 설정된다")
        fun `create error response when required fields expect all properties set correctly`() {
            val timestamp = LocalDateTime.now()
            val status = 400
            val error = "Bad Request"
            val errorCode = "VALIDATION_ERROR"
            val message = "유효성 검사에 실패했습니다"

            val errorResponse =
                ErrorResponse(
                    timestamp = timestamp,
                    status = status,
                    error = error,
                    errorCode = errorCode,
                    message = message,
                )

            assertThat(errorResponse.timestamp).isEqualTo(timestamp)
            assertThat(errorResponse.status).isEqualTo(status)
            assertThat(errorResponse.error).isEqualTo(error)
            assertThat(errorResponse.errorCode).isEqualTo(errorCode)
            assertThat(errorResponse.message).isEqualTo(message)
            assertThat(errorResponse.path).isNull()
            assertThat(errorResponse.traceId).isNull()
        }

        @Test
        @DisplayName("모든 필드로 ErrorResponse를 생성할 때 선택적 필드도 올바르게 설정된다")
        fun `create error response when all fields expect optional fields set correctly`() {
            val timestamp = LocalDateTime.now()
            val status = 404
            val error = "Not Found"
            val errorCode = "RESOURCE_NOT_FOUND"
            val message = "리소스를 찾을 수 없습니다"
            val path = "/api/users/123"
            val traceId = "abc123"

            val errorResponse =
                ErrorResponse(
                    timestamp = timestamp,
                    status = status,
                    error = error,
                    errorCode = errorCode,
                    message = message,
                    path = path,
                    traceId = traceId,
                )

            assertThat(errorResponse.timestamp).isEqualTo(timestamp)
            assertThat(errorResponse.status).isEqualTo(status)
            assertThat(errorResponse.error).isEqualTo(error)
            assertThat(errorResponse.errorCode).isEqualTo(errorCode)
            assertThat(errorResponse.message).isEqualTo(message)
            assertThat(errorResponse.path).isEqualTo(path)
            assertThat(errorResponse.traceId).isEqualTo(traceId)
        }

        @Test
        @DisplayName("ErrorResponse의 data class 기능이 올바르게 동작한다")
        fun `error response when data class expect copy and equals work correctly`() {
            val original =
                ErrorResponse(
                    timestamp = LocalDateTime.now(),
                    status = 500,
                    error = "Internal Server Error",
                    errorCode = "INTERNAL_ERROR",
                    message = "내부 서버 오류",
                )

            val copied =
                original.copy(
                    status = 503,
                    error = "Service Unavailable",
                    errorCode = "SERVICE_UNAVAILABLE",
                )

            assertThat(copied.timestamp).isEqualTo(original.timestamp)
            assertThat(copied.status).isEqualTo(503)
            assertThat(copied.error).isEqualTo("Service Unavailable")
            assertThat(copied.errorCode).isEqualTo("SERVICE_UNAVAILABLE")
            assertThat(copied.message).isEqualTo(original.message)
            assertThat(copied).isNotEqualTo(original)
        }
    }
}
