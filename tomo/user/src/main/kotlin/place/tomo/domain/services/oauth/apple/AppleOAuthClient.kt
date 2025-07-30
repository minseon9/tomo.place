package place.tomo.domain.services.oauth.apple

import com.fasterxml.jackson.databind.ObjectMapper
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.SignatureAlgorithm
import org.springframework.core.io.ResourceLoader
import org.springframework.stereotype.Component
import place.tomo.common.http.HttpClient
import place.tomo.common.http.post
import place.tomo.domain.constant.OAuthProvider
import place.tomo.domain.models.OAuthTokenResponse
import place.tomo.domain.models.OAuthUserInfo
import place.tomo.domain.services.oauth.OAuthClient
import java.security.KeyFactory
import java.security.PrivateKey
import java.security.spec.PKCS8EncodedKeySpec
import java.time.Instant
import java.util.Base64
import java.util.Date

// @FeignClient(
//    name = "AppleOAuthClient",
//    url = "https://appleid.apple.com",
//    configuration = AppleOAuthConfig.class)
//            public interface AppleOAuthClient {
//
//        @PostMapping("/auth/token?grant_type=authorization_code")
//        AppleTokenResponse appleAuth(
//        @RequestParam("client_id") String clientId,
//        @RequestParam("redirect_uri") String redirectUri,
//        @RequestParam("code") String code,
//        @RequestParam("client_secret") String clientSecret);
//    }
@Component
class AppleOAuthClient(
    private val httpClient: HttpClient,
    private val oAuthProperties: AppleOAuthProperties,
    private val resourceLoader: ResourceLoader,
    private val objectMapper: ObjectMapper,
) : OAuthClient {
    private val privateKey: PrivateKey by lazy {
        val resource = resourceLoader.getResource(oAuthProperties.keyPath)
        val keyBytes = resource.inputStream.readBytes()
        val keySpec = PKCS8EncodedKeySpec(Base64.getDecoder().decode(keyBytes))
        KeyFactory.getInstance("EC").generatePrivate(keySpec)
    }

    override suspend fun getAccessToken(authorizationCode: String): OAuthTokenResponse {
        val clientSecret = createClientSecret()

        val response =
            httpClient.post<AppleTokenResponse>(
                uri = oAuthProperties.tokenUri,
                body =
                    mapOf(
                        "client_id" to oAuthProperties.clientId,
                        "client_secret" to clientSecret,
                        "code" to authorizationCode,
                        "grant_type" to "authorization_code",
                        "redirect_uri" to oAuthProperties.redirectUri,
                    ),
            )

        // Apple ID token에서 사용자 정보 추출
        val claims =
            Jwts
                .parser()
                .build()
                .parseClaimsJwt(response.id_token)
                .payload

        // 사용자 정보를 함께 저장
        userInfo =
            AppleUserInfo(
                sub = claims["sub"] as String,
                email = claims["email"] as? String,
                name = null, // Apple은 최초 로그인 시에만 이름 제공
            )

        return OAuthTokenResponse(
            accessToken = response.access_token,
            refreshToken = response.refresh_token,
            expiresIn = response.expires_in,
        )
    }

    override suspend fun getUserInfo(accessToken: String): OAuthUserInfo {
        // Apple은 userInfo 엔드포인트가 없어서 토큰에서 추출한 정보 사용
        val info = userInfo ?: throw IllegalStateException("Apple 사용자 정보가 없습니다.")

        return OAuthUserInfo(
            provider = OAuthProvider.APPLE,
            socialId = info.sub,
            email = info.email,
            name = info.name,
            profileImageUrl = null, // Apple은 프로필 이미지 미제공
        )
    }

    private fun createClientSecret(): String {
        val now = Instant.now()

        return Jwts
            .builder()
            .header()
            .keyId(oAuthProperties.keyId)
            .and()
            .issuer(oAuthProperties.teamId)
            .audience()
            .add("https://appleid.apple.com")
            .and()
            .subject(oAuthProperties.clientId)
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plusSeconds(3600))) // 1시간
            .signWith(privateKey, SignatureAlgorithm.ES256)
            .compact()
    }

    private data class AppleTokenResponse(
        val access_token: String,
        val token_type: String,
        val expires_in: Long,
        val refresh_token: String?,
        val id_token: String,
    )

    private data class AppleUserInfo(
        val sub: String,
        val email: String?,
        val name: String?,
    )

    private companion object {
        private var userInfo: AppleUserInfo? = null
    }
}
