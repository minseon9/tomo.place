/// OAuth 결과 통합 모델
/// 
/// 모든 OAuth Provider의 인증 결과를 통일된 형태로 표현합니다.
class OAuthResult {
  final bool success;
  final bool cancelled;
  final String? authorizationCode; // OIDC Authorization Code
  final String? error;
  final String? errorCode;

  const OAuthResult({
    required this.success,
    this.cancelled = false,
    this.authorizationCode,
    this.error,
    this.errorCode,
  });

  /// 성공 결과 생성
  factory OAuthResult.success({
    required String authorizationCode,
  }) {
    return OAuthResult(
      success: true,
      authorizationCode: authorizationCode,
    );
  }

  /// 실패 결과 생성
  factory OAuthResult.failure({
    required String error,
    String? errorCode,
  }) {
    return OAuthResult(
      success: false,
      error: error,
      errorCode: errorCode,
    );
  }

  /// 사용자 취소 결과 생성
  factory OAuthResult.cancelled() {
    return const OAuthResult(
      success: false,
      cancelled: true,
      error: 'User cancelled authentication',
      errorCode: 'USER_CANCELLED',
    );
  }
}
