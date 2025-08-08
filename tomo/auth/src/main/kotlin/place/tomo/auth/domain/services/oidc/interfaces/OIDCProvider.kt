// package place.tomo.auth.domain.services.oidc.interfaces
//
// import place.tomo.auth.domain.models.OidcToken
// import place.tomo.domain.models.OidcUserInfo
//
// interface OIDCProvider {
//    suspend fun getTokenResponse(
//        authorizationCode: String,
//        state: String?,
//        clientSecret: String? = null,
//    ): OidcToken
//
//    suspend fun getUserInfoFromIdToken(idToken: String): OidcUserInfo
// }
//
// abstract class AbstractOidcProvider<T, P>(
//    protected val oidcClient: OidcClient<T>,
//    protected val oidcProperties: OidcProperties,
// ) : OIDCProvider {
//    override suspend fun getTokenResponse(
//        authorizationCode: String,
//        state: String?,
//        clientSecret: String?,
//    ): OidcToken {
//        // 1. 토큰 요청 (공통 플로우)
//        val tokenResponse =
//            oidcClient.getToken(
//                authorizationCode = authorizationCode,
//                clientId = oidcProperties.clientId,
//                clientSecret = clientSecret ?: oidcProperties.clientSecret,
//                redirectUri = oidcProperties.redirectUri,
//                grantType = "authorization_code",
//            )
//
//        // 2. 응답 검증 (각 Provider별 특화)
//        validateTokenResponse(tokenResponse, state)
//
//        // 3. 공통 형태로 변환 (각 Provider별 특화)
//        return mapToOAuthTokenResponse(tokenResponse)
//    }
//
//    override suspend fun getUserInfoFromIdToken(idToken: String): OidcUserInfo {
//        // 1. ID 토큰 파싱 (공통 플로우)
//        val parsedToken = parseIdToken(idToken)
//
//        // 2. 토큰 검증 (각 Provider별 특화)
//        validateIdToken(parsedToken)
//
//        // 3. 공통 형태로 변환 (각 Provider별 특화)
//        return mapToOAuthUserInfo(parsedToken)
//    }
//
//    protected abstract fun parseIdToken(idToken: String): P
//
//    protected abstract fun mapToOAuthTokenResponse(tokenResponse: T): OidcToken
//
//    protected abstract fun mapToOAuthUserInfo(parsedToken: P): OidcUserInfo
//
//    // 기본 구현을 제공하되, 필요시 override 가능한 메서드들
//    protected open fun validateTokenResponse(
//        tokenResponse: T,
//        state: String?,
//    ) {
//        if (!state.isNullOrEmpty()) {
//            throw IllegalArgumentException("state가 존재하는 경우, state 검증을 구현해야합니다.")
//        }
//        // 기본적으로는 아무것도 하지 않음
//        // 각 Provider에서 필요시 override (state 검증 등)
//    }
//
//    protected open fun validateIdToken(parsedToken: P) {
//        // 기본적으로는 아무것도 하지 않음
//        // 각 Provider에서 필요시 override (signature 검증, audience 검증 등)
//    }
// }
