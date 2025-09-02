package place.tomo.auth.domain.services

import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtException
import org.springframework.stereotype.Service
import place.tomo.auth.domain.exception.InvalidRefreshTokenException
import java.time.Instant

@Service
class RefreshTokenValidationService(
    private val jwtDecoder: JwtDecoder,
) {
    /**
     * Refresh Token을 검증하고 subject(사용자 이메일)를 반환합니다.
     * 
     * @param refreshToken 검증할 refresh token
     * @return 토큰의 subject (사용자 이메일)
     * @throws InvalidRefreshTokenException 토큰이 유효하지 않거나 만료된 경우
     */
    fun validateRefreshToken(refreshToken: String): String {
        try {
            val jwt = jwtDecoder.decode(refreshToken)
            
            // 토큰 만료 여부 확인
            val expiration = jwt.expiresAt
            if (expiration != null && expiration.isBefore(Instant.now())) {
                throw InvalidRefreshTokenException("Refresh token has expired")
            }
            
            // subject가 있는지 확인
            val subject = jwt.subject
            if (subject.isNullOrBlank()) {
                throw InvalidRefreshTokenException("Refresh token missing subject")
            }
            
            return subject
        } catch (e: JwtException) {
            throw InvalidRefreshTokenException("Invalid refresh token: ${e.message}")
        }
    }
}
