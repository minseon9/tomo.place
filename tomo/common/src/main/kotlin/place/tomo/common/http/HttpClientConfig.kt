package place.tomo.common.http

import kotlinx.coroutines.reactor.awaitSingle
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.MediaType
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.web.util.UriComponentsBuilder
import java.net.URI

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
        query: Map<String, String>?,
        responseType: Class<T>,
        contentType: MediaType,
    ): T {
        val resolvedUri = buildUriWithQuery(uri, query)

        val requestSpec =
            webClient
                .post()
                .uri(URI.create(resolvedUri))
                .contentType(contentType)

        val responseSpec = if (body.isEmpty()) requestSpec else requestSpec.bodyValue(body)

        return responseSpec
            .retrieve()
            .bodyToMono(responseType)
            .awaitSingle()
    }

    override suspend fun <T> get(
        uri: String,
        query: Map<String, String>?,
        responseType: Class<T>,
        accessToken: String?,
    ): T {
        val resolvedUri = buildUriWithQuery(uri, query)
        val request = webClient.get().uri(URI.create(resolvedUri))

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

    private fun buildUriWithQuery(
        baseUri: String,
        query: Map<String, String>?,
    ): String {
        if (query.isNullOrEmpty()) return baseUri

        return UriComponentsBuilder
            .fromUriString(baseUri)
            .apply { query.forEach { (k, v) -> queryParam(k, v) } }
            .build(true)
            .toUriString()

//        val builder = StringBuilder(baseUri).append('?')
//        val appended = query.entries.joinToString("&") { (key, value) -> "$key=$value" }
//        builder.append(appended)
//
//        return builder.toString()
    }
}
