/// 서버 관련 예외 클래스
/// 
/// API 서버에서 반환하는 HTTP 에러 응답을 처리합니다.
class ServerException implements Exception {
  final String message; // For logging
  final String userMessage; // For UI display
  final int statusCode;
  
  const ServerException(
    this.message, {
    required this.userMessage,
    required this.statusCode,
  });

  /// 400 Bad Request
  factory ServerException.badRequest({
    required String message,
  }) {
    return ServerException(
      'Bad request: $message',
      userMessage: '잘못된 요청입니다. 다시 시도해주세요.',
      statusCode: 400,
    );
  }

  /// 401 Unauthorized
  factory ServerException.unauthorized({
    required String message,
  }) {
    return ServerException(
      'Unauthorized: $message',
      userMessage: '인증이 필요합니다. 다시 로그인해주세요.',
      statusCode: 401,
    );
  }

  /// 403 Forbidden
  factory ServerException.forbidden({
    required String message,
  }) {
    return ServerException(
      'Forbidden: $message',
      userMessage: '접근 권한이 없습니다.',
      statusCode: 403,
    );
  }

  /// 404 Not Found
  factory ServerException.notFound({
    required String message,
  }) {
    return ServerException(
      'Not found: $message',
      userMessage: '요청한 페이지를 찾을 수 없습니다.',
      statusCode: 404,
    );
  }

  /// 500 Internal Server Error
  factory ServerException.internalServerError({
    required String message,
  }) {
    return ServerException(
      'Internal server error: $message',
      userMessage: '서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      statusCode: 500,
    );
  }

  /// 502 Bad Gateway
  factory ServerException.badGateway({
    required String message,
  }) {
    return ServerException(
      'Bad gateway: $message',
      userMessage: '서버 연결 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      statusCode: 502,
    );
  }

  /// 503 Service Unavailable
  factory ServerException.serviceUnavailable({
    required String message,
  }) {
    return ServerException(
      'Service unavailable: $message',
      userMessage: '서비스를 일시적으로 사용할 수 없습니다. 잠시 후 다시 시도해주세요.',
      statusCode: 503,
    );
  }

  /// HTTP 상태 코드에 따른 자동 생성
  factory ServerException.fromStatusCode({
    required int statusCode,
    required String message,
  }) {
    String userMessage;
    
    if (statusCode >= 400 && statusCode < 500) {
      // Client errors
      switch (statusCode) {
        case 400:
          userMessage = '잘못된 요청입니다. 다시 시도해주세요.';
          break;
        case 401:
          userMessage = '인증이 필요합니다. 다시 로그인해주세요.';
          break;
        case 403:
          userMessage = '접근 권한이 없습니다.';
          break;
        case 404:
          userMessage = '요청한 페이지를 찾을 수 없습니다.';
          break;
        default:
          userMessage = '요청 처리 중 오류가 발생했습니다.';
      }
    } else if (statusCode >= 500) {
      // Server errors
      userMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    } else {
      userMessage = '알 수 없는 서버 오류가 발생했습니다.';
    }

    return ServerException(
      'HTTP $statusCode: $message',
      userMessage: userMessage,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ServerException(statusCode: $statusCode, message: $message)';
  }
}
