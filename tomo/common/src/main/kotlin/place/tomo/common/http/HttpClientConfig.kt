package place.tomo.common.http

import kotlinx.coroutines.reactor.awaitSingle
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.MediaType
import org.springframework.web.reactive.function.client.WebClient

@Configuration
class HttpClientConfig {
    @Bean
    fun httpClientInterface(webClient: WebClient): HttpClient = HttpClientImpl(webClient)
}

private class HttpClientImpl(
    private val webClient: WebClient,
) : HttpClient {
    override suspend fun <T> post(
        uri: String,
        body: Map<String, String>,
        responseType: Class<T>,
        contentType: MediaType,
    ): T =
        webClient
            .post()
            .uri(uri)
            .contentType(contentType)
            .bodyValue(body)
            .retrieve()
            .bodyToMono(responseType)
            .awaitSingle()

    override suspend fun <T> get(
        uri: String,
        responseType: Class<T>,
        accessToken: String?,
    ): T {
        val request = webClient.get().uri(uri)

        if (accessToken != null) {
            request.headers { headers ->
                headers.setBearerAuth(accessToken)
            }
        }

        return request
            .retrieve()
            .bodyToMono(responseType)
            .awaitSingle()
    }
}
