package place.tomo.common.exception

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import java.time.LocalDateTime

@DisplayName("BaseException")
class BaseExceptionTest {
    @Nested
    @DisplayName("BaseHttpException")
    inner class BaseHttpExceptionTest {
        @Test
        @DisplayName("기본 생성자로 BaseHttpException을 생성할 때 모든 속성이 올바르게 설정된다")
        fun `create base http exception when basic constructor expect all properties set correctly`() {
            val status = HttpStatus.BAD_REQUEST
            val errorCode = "TEST_ERROR"
            val message = "테스트 에러 메시지"
            val timestamp = LocalDateTime.now()

            val exception =
                TestBaseHttpException(
                    status = status,
                    errorCode = errorCode,
                    message = message,
                    timestamp = timestamp,
                )

            assertThat(exception.status).isEqualTo(status)
            assertThat(exception.errorCode).isEqualTo(errorCode)
            assertThat(exception.message).isEqualTo(message)
            assertThat(exception.timestamp).isEqualTo(timestamp)
            assertThat(exception.parameters).isEmpty()
            assertThat(exception.cause).isNull()
        }

        @Test
        @DisplayName("파라미터가 있는 BaseHttpException을 생성할 때 getFormattedMessage가 파라미터를 치환한다")
        fun `create base http exception when with parameters expect formatted message replaces parameters`() {
            val message = "사용자 {userId}의 {action}이 실패했습니다"
            val parameters = mapOf("userId" to "123", "action" to "로그인")

            val exception =
                TestBaseHttpException(
                    status = HttpStatus.BAD_REQUEST,
                    errorCode = "TEST_ERROR",
                    message = message,
                    parameters = parameters,
                )

            assertThat(exception.getFormattedMessage()).isEqualTo("사용자 123의 로그인이 실패했습니다")
        }

        @Test
        @DisplayName("파라미터가 없는 BaseHttpException의 getFormattedMessage는 원본 메시지를 반환한다")
        fun `get formatted message when no parameters expect original message returned`() {
            val message = "테스트 에러 메시지"

            val exception =
                TestBaseHttpException(
                    status = HttpStatus.BAD_REQUEST,
                    errorCode = "TEST_ERROR",
                    message = message,
                )

            assertThat(exception.getFormattedMessage()).isEqualTo(message)
        }

        @Test
        @DisplayName("BaseHttpException의 toString은 클래스명과 에러코드, 메시지를 포함한다")
        fun `toString when base http exception expect contains class name error code and message`() {
            val exception =
                TestBaseHttpException(
                    status = HttpStatus.BAD_REQUEST,
                    errorCode = "TEST_ERROR",
                    message = "테스트 메시지",
                )

            val result = exception.toString()

            assertThat(result).contains("TestBaseHttpException")
            assertThat(result).contains("errorCode=TEST_ERROR")
            assertThat(result).contains("message=테스트 메시지")
        }
    }

    private class TestBaseHttpException(
        status: HttpStatus,
        errorCode: String,
        message: String,
        parameters: Map<String, Any> = emptyMap(),
        cause: Throwable? = null,
        timestamp: LocalDateTime = LocalDateTime.now(),
    ) : BaseHttpException(status, errorCode, message, parameters, cause, timestamp)
}
