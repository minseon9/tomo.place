/// 네트워크 관련 예외 클래스
/// 
/// API 통신, 연결 타임아웃 등 네트워크 계층에서 발생하는 예외를 처리합니다.
class NetworkException implements Exception {
  final String message; // For logging
  final String userMessage; // For UI display
  final int? statusCode;
  
  const NetworkException(
    this.message, {
    required this.userMessage,
    this.statusCode,
  });

  /// 연결 타임아웃
  factory NetworkException.connectionTimeout() {
    return const NetworkException(
      'Connection timeout occurred',
      userMessage: '네트워크 연결 시간이 초과되었습니다. 다시 시도해주세요.',
    );
  }

  /// 서버 응답 타임아웃
  factory NetworkException.receiveTimeout() {
    return const NetworkException(
      'Receive timeout occurred',
      userMessage: '서버 응답 시간이 초과되었습니다. 다시 시도해주세요.',
    );
  }

  /// 네트워크 연결 없음
  factory NetworkException.noConnection() {
    return const NetworkException(
      'No network connection available',
      userMessage: '네트워크 연결을 확인하고 다시 시도해주세요.',
    );
  }

  @override
  String toString() => 'NetworkException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}
