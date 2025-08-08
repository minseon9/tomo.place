// package place.tomo.auth.domain.services.oidc.google
//
// import com.fasterxml.jackson.annotation.JsonProperty
//
// data class GoogleTokenResponse(
//    @JsonProperty("access_token")
//    val accessToken: String,
//    @JsonProperty("expires_in")
//    val expiresIn: Long,
//    @JsonProperty("id_token")
//    val idToken: String,
//    @JsonProperty("scope")
//    val scope: String,
//    @JsonProperty("token_type")
//    val tokenType: String,
//    @JsonProperty("refresh_token")
//    val refreshToken: String?,
//    @JsonProperty("state")
//    val state: String?,
// )
//
// data class GoogleIdTokenPayload(
//    @JsonProperty("sub")
//    val sub: String,
//    @JsonProperty("email")
//    val email: String?,
//    @JsonProperty("email_verified")
//    val emailVerified: Boolean?,
//    @JsonProperty("name")
//    val name: String?,
//    @JsonProperty("picture")
//    val picture: String?,
//    @JsonProperty("given_name")
//    val givenName: String?,
//    @JsonProperty("family_name")
//    val familyName: String?,
//    @JsonProperty("aud")
//    val aud: String, // audience - 토큰 검증용
//    @JsonProperty("iss")
//    val iss: String, // issuer - 토큰 검증용
//    @JsonProperty("exp")
//    val exp: Long, // expiration time - 토큰 검증용
//    @JsonProperty("iat")
//    val iat: Long, // issued at - 토큰 검증용
// )
