package place.tomo.common.http

import org.springframework.http.MediaType

interface HttpClient {
    suspend fun <T> post(
        uri: String,
        body: Map<String, String>,
        responseType: Class<T>,
        contentType: MediaType = MediaType.APPLICATION_FORM_URLENCODED,
    ): T

    suspend fun <T> get(
        uri: String,
        responseType: Class<T>,
        accessToken: String? = null,
    ): T
}

suspend inline fun <reified T> HttpClient.post(
    uri: String,
    body: Map<String, String>,
    contentType: MediaType = MediaType.APPLICATION_FORM_URLENCODED,
): T = post(uri, body, T::class.java, contentType)

suspend inline fun <reified T> HttpClient.get(
    uri: String,
    accessToken: String? = null,
): T = get(uri, T::class.java, accessToken)
