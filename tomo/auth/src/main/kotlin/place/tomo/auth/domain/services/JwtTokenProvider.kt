package place.tomo.auth.domain.services

import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.stereotype.Service
import java.time.Instant
import java.util.Date

@Service
class JwtTokenProvider {
    // 32byte 이상의 임의의 시크릿 키 (예시)
    private val secretKey = "d8f3b2c1e4a7f6b9c2d1e8f7a6b5c4d3d8f3b2c1e4a7f6b9c2d1e8f7a6b5c4d3" // 64byte
    private val key = Keys.hmacShaKeyFor(secretKey.toByteArray())

    companion object {
        private const val ACCESS_TOKEN_EXPIRATION: Long = 60 * 60 * 24 * 7 // 7 days
        private const val REFRESH_TOKEN_EXPIRATION: Long = 60 * 60 * 24 * 365 // 365 days
        private const val ISSUER = "place.tomo"
    }

    fun issueAccessToken(subject: String): String = issueToken(subject, ACCESS_TOKEN_EXPIRATION)

    fun issueRefreshToken(subject: String): String = issueToken(subject, REFRESH_TOKEN_EXPIRATION)

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
            .issuer(ISSUER)
            .issuedAt(Date.from(nowInstant))
            .expiration(Date.from(nowInstant.plusSeconds(expiration)))
            .signWith(key, Jwts.SIG.HS256)
            .compact()
    }
}
