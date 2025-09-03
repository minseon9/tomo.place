class ErrorCodes {
  // Network 관련
  /// 연결 타임아웃
  static const String connectionTimeout = 'NET_001';

  /// 응답 타임아웃
  static const String receiveTimeout = 'NET_002';

  /// 네트워크 연결 없음
  static const String noConnection = 'NET_003';

  /// DNS 해석 실패
  static const String dnsResolutionFailed = 'NET_004';

  /// SSL/TLS 인증서 오류
  static const String sslCertificateError = 'NET_005';

  /// 요청 취소
  static const String requestCancelled = 'NET_006';

  /// 잘못된 응답
  static const String badResponse = 'NET_007';

  /// 연결 오류
  static const String connectionError = 'NET_008';

  /// 보안 연결 실패
  static const String securityConnectionFailed = 'NET_009';

  // Server 관련 (HTTP 상태 코드 기반)
  /// 400 Bad Request
  static const String badRequest = 'SRV_400';

  /// 401 Unauthorized
  static const String unauthorized = 'SRV_401';

  /// 403 Forbidden
  static const String forbidden = 'SRV_403';

  /// 404 Not Found
  static const String notFound = 'SRV_404';

  /// 405 Method Not Allowed
  static const String methodNotAllowed = 'SRV_405';

  /// 409 Conflict
  static const String conflict = 'SRV_409';

  /// 422 Unprocessable Entity
  static const String unprocessableEntity = 'SRV_422';

  /// 429 Too Many Requests
  static const String tooManyRequests = 'SRV_429';

  /// 500 Internal Server Error
  static const String internalServerError = 'SRV_500';

  /// 502 Bad Gateway
  static const String badGateway = 'SRV_502';

  /// 503 Service Unavailable
  static const String serviceUnavailable = 'SRV_503';

  /// 504 Gateway Timeout
  static const String gatewayTimeout = 'SRV_504';
}
