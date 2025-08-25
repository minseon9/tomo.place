package place.tomo.common.http

import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.http.MediaType

@DisplayName("HttpClient")
class HttpClientTest {
    private lateinit var httpClient: HttpClient

    @BeforeEach
    fun setUp() {
        httpClient = mockk()
    }

    @Nested
    @DisplayName("POST 요청")
    inner class PostRequest {
        @Test
        @DisplayName("기본 POST 요청 시 올바른 파라미터로 호출된다")
        fun `post request when basic parameters expect called with correct parameters`() =
            runBlocking {
                val uri = "https://api.example.com/test"
                val body = mapOf("key" to "value")
                val query = mapOf("param" to "value")
                val responseType = TestResponse::class.java
                val contentType = MediaType.APPLICATION_JSON
                val expectedResponse = TestResponse("success")

                coEvery {
                    httpClient.post(uri, body, query, responseType, contentType)
                } returns expectedResponse

                val result = httpClient.post(uri, body, query, responseType, contentType)

                assertThat(result).isEqualTo(expectedResponse)
                coVerify { httpClient.post(uri, body, query, responseType, contentType) }
            }

        @Test
        @DisplayName("기본값으로 POST 요청 시 올바른 기본값이 적용된다")
        fun `post request when default parameters expect default values applied`() =
            runBlocking {
                val uri = "https://api.example.com/test"
                val responseType = TestResponse::class.java
                val expectedResponse = TestResponse("success")

                coEvery {
                    httpClient.post(uri, emptyMap(), null, responseType, MediaType.APPLICATION_JSON)
                } returns expectedResponse

                val result = httpClient.post(uri, responseType = responseType)

                assertThat(result).isEqualTo(expectedResponse)
                coVerify { httpClient.post(uri, emptyMap(), null, responseType, MediaType.APPLICATION_JSON) }
            }

        @Test
        @DisplayName("reified 타입으로 POST 요청 시 올바른 타입이 전달된다")
        fun `post request when reified type expect correct type passed`() =
            runBlocking {
                val uri = "https://api.example.com/test"
                val expectedResponse = TestResponse("success")

                coEvery {
                    httpClient.post(uri, emptyMap(), null, TestResponse::class.java, MediaType.APPLICATION_JSON)
                } returns expectedResponse

                val result: TestResponse = httpClient.post(uri)

                assertThat(result).isEqualTo(expectedResponse)
                coVerify { httpClient.post(uri, emptyMap(), null, TestResponse::class.java, MediaType.APPLICATION_JSON) }
            }
    }

    @Nested
    @DisplayName("GET 요청")
    inner class GetRequest {
        @Test
        @DisplayName("기본 GET 요청 시 올바른 파라미터로 호출된다")
        fun `get request when basic parameters expect called with correct parameters`() =
            runBlocking {
                val uri = "https://api.example.com/test"
                val query = mapOf("param" to "value")
                val responseType = TestResponse::class.java
                val accessToken = "bearer-token"
                val expectedResponse = TestResponse("success")

                coEvery {
                    httpClient.get(uri, query, responseType, accessToken)
                } returns expectedResponse

                val result = httpClient.get(uri, query, responseType, accessToken)

                assertThat(result).isEqualTo(expectedResponse)
                coVerify { httpClient.get(uri, query, responseType, accessToken) }
            }

        @Test
        @DisplayName("기본값으로 GET 요청 시 올바른 기본값이 적용된다")
        fun `get request when default parameters expect default values applied`() =
            runBlocking {
                val uri = "https://api.example.com/test"
                val responseType = TestResponse::class.java
                val expectedResponse = TestResponse("success")

                coEvery {
                    httpClient.get(uri, null, responseType, null)
                } returns expectedResponse

                val result = httpClient.get(uri, responseType = responseType)

                assertThat(result).isEqualTo(expectedResponse)
                coVerify { httpClient.get(uri, null, responseType, null) }
            }

        @Test
        @DisplayName("reified 타입으로 GET 요청 시 올바른 타입이 전달된다")
        fun `get request when reified type expect correct type passed`() =
            runBlocking {
                val uri = "https://api.example.com/test"
                val expectedResponse = TestResponse("success")

                coEvery {
                    httpClient.get(uri, null, TestResponse::class.java, null)
                } returns expectedResponse

                val result: TestResponse = httpClient.get(uri)

                assertThat(result).isEqualTo(expectedResponse)
                coVerify { httpClient.get(uri, null, TestResponse::class.java, null) }
            }
    }

    data class TestResponse(
        val message: String,
    )
}
