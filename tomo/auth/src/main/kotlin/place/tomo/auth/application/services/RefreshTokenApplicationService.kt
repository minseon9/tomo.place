package place.tomo.auth.application.services

import org.springframework.stereotype.Service
import place.tomo.auth.application.requests.RefreshTokenRequest
import place.tomo.auth.application.responses.RefreshTokenResponse
import place.tomo.auth.domain.services.JwtProvider
import place.tomo.auth.domain.services.RefreshTokenValidationService

@Service
class RefreshTokenApplicationService(
    private val refreshTokenValidationService: RefreshTokenValidationService,
    private val jwtProvider: JwtProvider,
) {
    /**
     * Refresh Token을 검증하고 새로운 Access Token과 Refresh Token을 발급합니다.
     * 
     * @param request Refresh Token 요청
     * @return 새로운 토큰 정보
     */
    fun refreshToken(request: RefreshTokenRequest): RefreshTokenResponse {
        // Refresh Token 검증 및 사용자 이메일 추출
        val userEmail = refreshTokenValidationService.validateRefreshToken(request.refreshToken)
        
        // 새로운 Access Token과 Refresh Token 발급
        val newAccessToken = jwtProvider.issueAccessToken(userEmail)
        val newRefreshToken = jwtProvider.issueRefreshToken(userEmail)
        
        return RefreshTokenResponse(
            accessToken = newAccessToken.token,
            refreshToken = newRefreshToken.token,
            accessTokenExpiresAt = newAccessToken.expiresAt,
            refreshTokenExpiresAt = newRefreshToken.expiresAt
        )
    }
}
