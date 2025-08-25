package place.tomo.auth.domain.services

import io.jsonwebtoken.Jwts
import io.jsonwebtoken.io.Decoders
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import place.tomo.auth.domain.exception.InvalidAuthTokenException
import java.time.Instant
import java.util.Date

// TODO: Spring Security의 OAuth2 Resource Server 를 사용하도록 리팩토링
// TODO: provider, decoder, validator를 책임 분리
@Service
class JwtTokenProvider(
    @Value("\${security.jwt.secret}") private val secret: String,
    @Value("\${security.jwt.issuer}") private val issuer: String,
    @Value("\${security.jwt.access-ttl-seconds}") private val accessTtlSeconds: Long,
    @Value("\${security.jwt.refresh-ttl-seconds}") private val refreshTtlSeconds: Long,
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
            val parsed =
                Jwts
                    .parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(jwt)

            return parsed.payload.expiration > Date.from(Instant.now())
        } catch (e: Exception) {
            return false
        }
    }

    fun getUsernameFromToken(jwt: String): String {
        if (!validateToken(jwt)) {
            throw InvalidAuthTokenException()
        }

        return Jwts
            .parser()
            .verifyWith(key)
            .build()
            .parseSignedClaims(jwt)
            .payload.subject
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
