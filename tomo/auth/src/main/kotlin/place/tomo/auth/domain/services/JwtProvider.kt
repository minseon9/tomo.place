package place.tomo.auth.domain.services

import org.springframework.beans.factory.annotation.Value
import org.springframework.security.oauth2.jose.jws.SignatureAlgorithm
import org.springframework.security.oauth2.jwt.JwsHeader
import org.springframework.security.oauth2.jwt.JwtClaimsSet
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.JwtEncoderParameters
import org.springframework.stereotype.Service
import java.time.Instant

@Service
class JwtProvider(
    @Value("\${security.jwt.issuer}") private val issuer: String,
    @Value("\${security.jwt.audiences}") private val audiences: List<String>,
    @Value("\${security.jwt.access-ttl-seconds}") private val accessTtlSeconds: Long,
    @Value("\${security.jwt.refresh-ttl-seconds}") private val refreshTtlSeconds: Long,
    private val jwtEncoder: JwtEncoder,
) {
    fun issueAccessToken(subject: String): String = issueToken(subject, accessTtlSeconds)

    fun issueRefreshToken(subject: String): String = issueToken(subject, refreshTtlSeconds)

    private fun issueToken(
        subject: String,
        expiration: Long,
    ): String {
        val nowInstant = Instant.now()

        val jwtClaims =
            JwtClaimsSet
                .builder()
                .subject(subject)
                .audience(audiences)
                .issuer(issuer)
                .issuedAt(nowInstant)
                .expiresAt(nowInstant.plusSeconds(expiration))
                .build()

        val jwsHeader = JwsHeader.with(SignatureAlgorithm.RS256).build()

        return jwtEncoder.encode(JwtEncoderParameters.from(jwsHeader, jwtClaims)).tokenValue
    }
}
