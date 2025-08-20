package place.tomo.auth.domain.services.oidc

import net.datafaker.Faker
import place.tomo.auth.domain.dtos.oidc.OIDCEndpoints
import place.tomo.auth.domain.dtos.oidc.OIDCIdTokenClaims
import place.tomo.auth.domain.dtos.oidc.OIDCTokens
import place.tomo.auth.domain.services.oidc.discovery.OIDCEndpointResolver
import place.tomo.auth.domain.services.oidc.discovery.OIDCJwksResolver

object OIDCTestHelper {
    private val faker = Faker()

    const val TEST_PROVIDER_NAME = "test provider"
    const val TEST_ISSUER = "https://test-issuer.com"
    const val TEST_AUTH_ENDPOINT = "https://test-auth.com"
    const val TEST_TOKEN_ENDPOINT = "https://test-token.com"
    const val TEST_USERINFO_ENDPOINT = "https://test-userinfo.com"
    const val TEST_JWKS_URI = "https://test-jwks.com"
    const val TEST_CLIENT_ID = "test-client-id"
    const val TEST_KID = "test-kid-1"
    const val TEST_ALG = "RS256"
    const val TEST_KEY_TYPE = "RSA"
    const val TEST_USE = "sig"
    const val TEST_MODULUS =
        "tH5pdWojgagY73Hy2WtH8vhoKpGAmP01E1CSuZn-02U_hTjFzAoDAiT6d7CcP14VHg4AGRWY82NCw5HL9vapXilR0Y1g3lFWwRCU1oXjApzhkTt3RVbM-jPWr5aEC_QN6yTE9qK1lwz1_x03rPMOuSP7BcDQCNazPLPwIDxMtzT47asH25OrtiN-nFA_imMAMrqKEBhmYtutGqKqhs6vI_PsNHxLFyR26Z-CgGrQ21Eensu0jl29vl0uYBfVUG4XpzOp7A5_rwVPaHx5ZibUSVG-eVu0RYObSKJTXQg8NKs3bEUHk9Z563PgTA9mf5VsvenNm6DxCJrvztxKvhg1Nw"
    const val TEST_EXPONENT = "AQAB"

    const val TEST_WELL_KNOWN_PATH = "/.well-known/openid-configuration"

    val TEST_EMAIL: String = faker.internet().emailAddress()
    val TEST_NAME: String = faker.name().fullName()
    val TEST_PICTURE: String = faker.internet().url()
    val TEST_SUBJECT: String = faker.internet().uuid()

    fun createOIDCTokens(
        accessToken: String = faker.internet().password(),
        refreshToken: String = faker.internet().password(),
        idToken: String = faker.internet().password(),
        expiresIn: Long = 3600L,
    ) = OIDCTokens(
        accessToken = accessToken,
        refreshToken = refreshToken,
        idToken = idToken,
        expiresIn = expiresIn,
    )

    fun createEndpoints(
        issuer: String = TEST_ISSUER,
        authorizationEndpoint: String = TEST_AUTH_ENDPOINT,
        tokenEndpoint: String = TEST_TOKEN_ENDPOINT,
        userinfoEndpoint: String = TEST_USERINFO_ENDPOINT,
        jwksUri: String = TEST_JWKS_URI,
    ) = OIDCEndpoints(
        issuer = issuer,
        authorizationEndpoint = authorizationEndpoint,
        tokenEndpoint = tokenEndpoint,
        userinfoEndpoint = userinfoEndpoint,
        jwksUri = jwksUri,
    )

    fun createClaims(
        issuer: String = TEST_ISSUER,
        subject: String = TEST_SUBJECT,
        audiences: List<String> = listOf(TEST_CLIENT_ID),
        email: String? = TEST_EMAIL,
        emailVerified: Boolean = true,
        name: String = TEST_NAME,
        picture: String? = TEST_PICTURE,
        expirationEpochSeconds: Long = System.currentTimeMillis() / 1000 + 3600,
        issuedAtEpochSeconds: Long = System.currentTimeMillis() / 1000,
    ) = OIDCIdTokenClaims(
        issuer = issuer,
        subject = subject,
        audiences = audiences,
        expirationEpochSeconds = expirationEpochSeconds,
        issuedAtEpochSeconds = issuedAtEpochSeconds,
        email = email,
        emailVerified = emailVerified,
        name = name,
        picture = picture,
    )

    fun createJwkKey(
        kty: String = TEST_KEY_TYPE,
        use: String? = TEST_USE,
        kid: String? = TEST_KID,
        alg: String? = TEST_ALG,
        n: String? = TEST_MODULUS, // 실제 RSA modulus 사용
        e: String? = TEST_EXPONENT, // 실제 RSA exponent 사용
        x5c: List<String>? = null,
    ) = OIDCJwksResolver.JwkKey(
        kty = kty,
        use = use,
        kid = kid,
        alg = alg,
        n = n,
        e = e,
        x5c = x5c,
    )

    fun createJwksResponse(keys: List<OIDCJwksResolver.JwkKey> = listOf(createJwkKey())) = OIDCJwksResolver.JwksResponse(keys = keys)

    fun createWellKnownResponse(
        issuer: String = TEST_ISSUER,
        authorizationEndpoint: String = TEST_AUTH_ENDPOINT,
        tokenEndpoint: String = TEST_TOKEN_ENDPOINT,
        userinfoEndpoint: String = TEST_USERINFO_ENDPOINT,
        jwksUri: String = TEST_JWKS_URI,
    ) = OIDCEndpointResolver.WellKnownResponse(
        issuer = issuer,
        authorization_endpoint = authorizationEndpoint,
        token_endpoint = tokenEndpoint,
        userinfo_endpoint = userinfoEndpoint,
        jwks_uri = jwksUri,
    )
}
