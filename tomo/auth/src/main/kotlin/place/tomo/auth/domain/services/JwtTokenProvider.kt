package place.tomo.auth.domain.services

import io.jsonwebtoken.Jwts
import io.jsonwebtoken.io.Decoders
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import java.time.Instant
import java.util.Date

@Service
class JwtTokenProvider(
    @Value("\${security.jwt.secret}") private val secret: String,
    @Value("\${security.jwt.issuer:place.tomo}") private val issuer: String,
    @Value("\${security.jwt.access-ttl-seconds:604800}") private val accessTtlSeconds: Long,
    @Value("\${security.jwt.refresh-ttl-seconds:31536000}") private val refreshTtlSeconds: Long,
) {
    private val key by lazy {
        val rawKeyBytes =
            try {
                Decoders.BASE64.decode(secret)
            } catch (e: Exception) {
                secret.toByteArray()
            }
        Keys.hmacShaKeyFor(rawKeyBytes)
    }

    fun issueAccessToken(subject: String): String = issueToken(subject, accessTtlSeconds)

    fun issueRefreshToken(subject: String): String = issueToken(subject, refreshTtlSeconds)

    fun validateToken(jwt: String): Boolean {
        try {
            Jwts
                .parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(jwt)
            return true
        } catch (e: Exception) {
            return false
        }
    }

    fun getUsernameFromToken(jwt: String): String {
        val claims =
            Jwts
                .parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(jwt)
                .payload

        return claims.subject
    }

    private fun issueToken(
        subject: String,
        expiration: Long,
    ): String {
        val nowInstant = Instant.now()
        return Jwts
            .builder()
            .subject(subject)
            .issuer(issuer)
            .issuedAt(Date.from(nowInstant))
            .expiration(Date.from(nowInstant.plusSeconds(expiration)))
            .signWith(key, Jwts.SIG.HS256)
            .compact()
    }
}
