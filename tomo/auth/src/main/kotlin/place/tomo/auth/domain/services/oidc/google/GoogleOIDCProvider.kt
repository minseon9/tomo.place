// package place.tomo.auth.domain.services.oidc.google
//
// import com.fasterxml.jackson.databind.ObjectMapper
// import org.springframework.stereotype.Component
// import place.tomo.auth.domain.models.OidcToken
// import place.tomo.auth.domain.models.OidcUserInfo
// import place.tomo.auth.domain.services.oidc.interfaces.AbstractOidcProvider
// import place.tomo.contract.constant.OIDCProviderType
// import java.util.Base64
//
// @Component
// class GoogleOIDCProvider(
//    googleOIDCClient: GoogleOIDCClient,
//    private val googleOAuthProperties: GoogleOAuthProperties,
//    private val objectMapper: ObjectMapper,
// ) : AbstractOidcProvider<GoogleTokenResponse, GoogleIdTokenPayload>(
//        oidcClient = googleOIDCClient,
//        oidcProperties = googleOAuthProperties,
//    ) {
//    override fun parseIdToken(idToken: String): GoogleIdTokenPayload {
//        val parts = idToken.split(".")
//        require(parts.size == 3) { "Invalid JWT format" }
//
//        val payload = parts[1]
//        val decodedBytes = Base64.getUrlDecoder().decode(payload)
//        val payloadJson = String(decodedBytes)
//
//        return objectMapper.readValue(payloadJson, GoogleIdTokenPayload::class.java)
//    }
//
//    override fun mapToOAuthTokenResponse(tokenResponse: GoogleTokenResponse): OidcToken =
//        OidcToken(
//            accessToken = tokenResponse.accessToken,
//            refreshToken = tokenResponse.refreshToken,
//            expiresIn = tokenResponse.expiresIn,
//            idToken = tokenResponse.idToken,
//        )
//
//    override fun mapToOAuthUserInfo(parsedToken: GoogleIdTokenPayload): OidcUserInfo =
//        OidcUserInfo(
//            provider = OIDCProviderType.GOOGLE,
//            socialId = parsedToken.sub,
//            email = parsedToken.email,
//            name = parsedToken.name,
//            profileImageUrl = parsedToken.picture,
//        )
//
//    // Google 특화 검증 로직
//    override fun validateIdToken(parsedToken: GoogleIdTokenPayload) {
//        // Google 특화 검증 로직
//        // 예: audience 검증, issuer 검증, 만료시간 검증 등
//        if (parsedToken.aud != googleOAuthProperties.clientId) {
//            throw IllegalArgumentException("Invalid audience in ID token")
//        }
//
//        if (parsedToken.iss != "https://accounts.google.com") {
//            throw IllegalArgumentException("Invalid issuer in ID token")
//        }
//
//        // 만료 시간 검증
//        val currentTime = System.currentTimeMillis() / 1000
//        if (parsedToken.exp < currentTime) {
//            throw IllegalArgumentException("ID token has expired")
//        }
//
//        // 추가 검증 로직...
//    }
//
//    // Google에서는 state 검증이 별도로 필요할 수 있음
//    override fun validateTokenResponse(
//        tokenResponse: GoogleTokenResponse,
//        state: String?,
//    ) {
//        if (state.isNullOrEmpty()) {
//            throw IllegalArgumentException("State <UNK> <UNK> <UNK>.")
//        }
//
//        // Google 특화 state 검증 로직
//        // 실제로는 토큰 응답에서 state를 확인하거나 별도 로직 필요
//        // 현재는 기본 구현 사용
//        if (state != tokenResponse.state) {
//            throw IllegalArgumentException("Invalid state")
//        }
//    }
// }
