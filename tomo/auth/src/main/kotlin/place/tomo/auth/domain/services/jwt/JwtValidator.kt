package place.tomo.auth.domain.services.jwt

import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtException
import org.springframework.stereotype.Service
import place.tomo.auth.domain.exception.InvalidRefreshTokenException

@Service
class JwtValidator(
    private val jwtDecoder: JwtDecoder,
) {
    fun validateRefreshToken(refreshToken: String): String {
        try {
            // NOTE: JwtConfig에서 validator들을 추가해, decode 시 iss, aud, exp에 대한 검증을 진행
            val jwt = jwtDecoder.decode(refreshToken)

            return jwt.subject
        } catch (e: JwtException) {
            throw InvalidRefreshTokenException("유효하지 않은 토큰입니다.: ${e.message}", e)
        }
    }
}
