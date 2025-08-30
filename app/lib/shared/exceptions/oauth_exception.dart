/// OAuth 관련 예외 클래스
/// 
/// 소셜 로그인 프로바이더 인증 과정에서 발생하는 예외를 처리합니다.
class OAuthException implements Exception {
  final String message; // For logging
  final String userMessage; // For UI display
  final String? provider;
  final String? errorCode;
  
  const OAuthException(
    this.message, {
    required this.userMessage,
    this.provider,
    this.errorCode,
  });

  /// 사용자가 로그인을 취소 (에러가 아닌 정상적인 플로우)
  factory OAuthException.userCancelled({String? provider}) {
    return OAuthException(
      'User cancelled OAuth flow',
      userMessage: '로그인이 취소되었습니다.',
      provider: provider,
    );
  }

  /// 네트워크 에러
  factory OAuthException.networkError({
    required String message,
    String? provider,
    dynamic originalError,
  }) {
    return OAuthException(
      'OAuth network error: $message',
      userMessage: '네트워크 오류가 발생했습니다. 다시 시도해주세요.',
      provider: provider,
    );
  }

  /// 인증 실패
  factory OAuthException.authenticationFailed({
    required String message,
    String? provider,
    String? errorCode,
    dynamic originalError,
  }) {
    return OAuthException(
      'OAuth authentication failed: $message',
      userMessage: '로그인에 실패했습니다. 다시 시도해주세요.',
      provider: provider,
      errorCode: errorCode,
    );
  }

  /// 서버 에러
  factory OAuthException.serverError({
    required String message,
    String? provider,
    String? errorCode,
    dynamic originalError,
  }) {
    return OAuthException(
      'OAuth server error: $message',
      userMessage: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      provider: provider,
      errorCode: errorCode,
    );
  }

  /// 권한 거부
  factory OAuthException.permissionDenied({
    String? provider,
    dynamic originalError,
  }) {
    return OAuthException(
      'OAuth permission denied',
      userMessage: '필요한 권한이 거부되었습니다.',
      provider: provider,
    );
  }

  /// 알 수 없는 에러
  factory OAuthException.unknown({
    required String message,
    String? provider,
    dynamic originalError,
  }) {
    return OAuthException(
      'OAuth unknown error: $message',
      userMessage: '알 수 없는 오류가 발생했습니다.',
      provider: provider,
    );
  }

  @override
  String toString() {
    return 'OAuthException(message: $message, provider: $provider, errorCode: $errorCode)';
  }
}
