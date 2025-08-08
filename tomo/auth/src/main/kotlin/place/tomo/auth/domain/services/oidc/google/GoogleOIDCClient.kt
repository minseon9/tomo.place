// package place.tomo.auth.domain.services.oidc.google
//
// import org.springframework.cloud.openfeign.FeignClient
// import org.springframework.web.bind.annotation.PostMapping
// import org.springframework.web.bind.annotation.RequestParam
// import place.tomo.auth.domain.services.oidc.interfaces.OidcClient
//
// @FeignClient(
//    name = "google-oidc",
// )
// interface GoogleOIDCClient : OidcClient<GoogleTokenResponse> {
//    @PostMapping(path = ["\${oauth2.google.token-uri}"])
//    override suspend fun getToken(
//        @RequestParam("code") authorizationCode: String,
//        @RequestParam("client_id") clientId: String,
//        @RequestParam("client_secret") clientSecret: String,
//        @RequestParam("redirect_uri") redirectUri: String,
//        @RequestParam("grant_type", defaultValue = "authorization_code") grantType: String,
//    ): GoogleTokenResponse
// }
