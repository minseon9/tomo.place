package dev.ian.mapa.application.services

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

    // TODO: JWT 발급 / 재발급 ?
    fun issueToken(subject: String): String {
        // signWith에 이미 선언된 key 사용
        val jwt =
            Jwts
                .builder()
                .header()
                .keyId("aKeyId")
                .and()
                .subject(subject)
                .issuer("ian")
                .issuedAt(Date.from(Instant.now()))
                .expiration(Date.from(Instant.now().plusSeconds(3600)))
                .audience()
                .add("ian")
                .and()
                .signWith(key, Jwts.SIG.HS256)
                .compact()

        return jwt
    }

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
}
