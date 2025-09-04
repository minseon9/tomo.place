class ExceptionTypes {
  // Network 관련
  /// 네트워크 일반
  static const String network = 'Network';

  /// 연결 관련
  static const String connection = 'Connection';

  /// 보안 관련
  static const String security = 'Security';

  /// 타임아웃 관련
  static const String timeout = 'Timeout';

  /// DNS 관련
  static const String dns = 'DNS';

  /// SSL/TLS 관련
  static const String ssl = 'SSL';

  /// 요청/응답 관련
  static const String requestResponse = 'RequestResponse';

  // Server 관련
  /// 서버 일반
  static const String server = 'Server';

  /// HTTP 관련
  static const String http = 'HTTP';

  /// API 관련
  static const String api = 'API';

  /// 클라이언트 오류 (4xx)
  static const String clientError = 'ClientError';

  /// 서버 오류 (5xx)
  static const String serverError = 'ServerError';

  /// 인증 관련
  static const String authentication = 'Authentication';

  /// 권한 관련
  static const String authorization = 'Authorization';

  /// 리소스 관련
  static const String resource = 'Resource';

  /// 비즈니스 로직 관련
  static const String businessLogic = 'BusinessLogic';
}
