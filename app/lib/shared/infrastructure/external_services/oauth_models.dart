// FIXME: models 들이 하나에 통합되어있어 구조 파악이 어렵고 가독이 좋지 않음
// FIXME: 에러는 아예 별개로 관리하도록

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

/// OAuth 에러 타입 열거형
/// 
/// 공통 에러 타입을 정의하여 일관된 에러 처리를 제공합니다.
enum OAuthErrorType {
  networkError,
  userCancelled,
  invalidCredentials,
  serverError,
  tokenExpired,
  permissionDenied,
  unknown,
}
