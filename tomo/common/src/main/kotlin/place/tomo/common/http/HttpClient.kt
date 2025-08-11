package place.tomo.common.http

import org.springframework.http.MediaType

interface HttpClient {
    suspend fun <T> post(
        uri: String,
        body: Map<String, String> = emptyMap(),
        query: Map<String, String>? = null,
        responseType: Class<T>,
        contentType: MediaType = MediaType.APPLICATION_JSON,
    ): T

    suspend fun <T> get(
        uri: String,
        query: Map<String, String>? = null,
        responseType: Class<T>,
        accessToken: String? = null,
    ): T
}

suspend inline fun <reified T> HttpClient.post(
    uri: String,
    body: Map<String, String> = emptyMap(),
    query: Map<String, String>? = null,
    contentType: MediaType = MediaType.APPLICATION_JSON,
): T = post(uri, body, query, T::class.java, contentType)

suspend inline fun <reified T> HttpClient.get(
    uri: String,
    query: Map<String, String>? = null,
    accessToken: String? = null,
): T = get(uri, query, T::class.java, accessToken)
