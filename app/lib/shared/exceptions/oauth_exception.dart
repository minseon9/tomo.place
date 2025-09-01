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

  factory OAuthException.signOutFailed({required String message, String? provider}) {
    return OAuthException(
      'OAuth sign out exception raised: $message',
      userMessage: '로그아웃이 실패했습니다.',
      provider: provider,
    );
  }

  factory OAuthException.authenticationFailed({required String message, String? provider}) {
    return OAuthException(
      'OAuth exception raised: $message',
      userMessage: '인증이 실패했습니다.',
      provider: provider,
    );
  }

  @override
  String toString() {
    return 'OAuthException(message: $message, provider: $provider, errorCode: $errorCode)';
  }
}
