package place.tomo.auth.domain.services.jwt

import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtException
import org.springframework.stereotype.Service
import place.tomo.auth.domain.exception.InvalidRefreshTokenException
import java.time.Instant

@Service
class JwtValidator(
    private val jwtDecoder: JwtDecoder,
) {
    fun validateRefreshToken(
        subject: String,
        refreshToken: String,
    ) {
        try {
            val jwt = jwtDecoder.decode(refreshToken)

            val expiration = jwt.expiresAt
            if (expiration != null && expiration.isBefore(Instant.now())) {
                throw InvalidRefreshTokenException("만료된 토큰입니다.")
            }

            if (jwt.subject != subject) {
                throw InvalidRefreshTokenException("유효하지 않는 subject입니다.")
            }
        } catch (e: JwtException) {
            throw InvalidRefreshTokenException("유효하지 않은 토큰입니다.: ${e.message}", e)
        }
    }
}
