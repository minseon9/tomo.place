package place.tomo.auth.domain.exception

/**
 * Refresh Token이 유효하지 않을 때 발생하는 예외
 */
class InvalidRefreshTokenException(message: String) : RuntimeException(message)
