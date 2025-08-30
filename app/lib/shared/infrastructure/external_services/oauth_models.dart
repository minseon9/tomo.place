// FIXME: models 들이 하나에 통합되어있어 구조 파악이 어렵고 가독이 좋지 않음
// FIXME: 에러는 아예 별개로 관리하도록

/// OAuth 결과 통합 모델
/// 
/// 모든 OAuth Provider의 인증 결과를 통일된 형태로 표현합니다.
class OAuthResult {
  final bool success;
  final String? authorizationCode; // OIDC Authorization Code
  final String? error;
  final String? errorCode;

  const OAuthResult({
    required this.success,
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

/// OAuth 예외 클래스
/// 
/// OAuth 관련 예외를 통일된 형태로 처리합니다.
class OAuthException implements Exception {
  final OAuthErrorType type;
  final String message;
  final String? provider;
  final String? errorCode;
  final dynamic originalError;
  
  const OAuthException({
    required this.type,
    required this.message,
    this.provider,
    this.errorCode,
    this.originalError,
  });

  /// 네트워크 에러 생성
  factory OAuthException.networkError({
    required String message,
    String? provider,
    dynamic originalError,
  }) {
    return OAuthException(
      type: OAuthErrorType.networkError,
      message: message,
      provider: provider,
      originalError: originalError,
    );
  }

  /// 사용자 취소 에러 생성
  factory OAuthException.userCancelled({
    String? provider,
    dynamic originalError,
  }) {
    return OAuthException(
      type: OAuthErrorType.userCancelled,
      message: '사용자가 로그인을 취소했습니다.',
      provider: provider,
      originalError: originalError,
    );
  }

  /// 인증 실패 에러 생성
  factory OAuthException.invalidCredentials({
    required String message,
    String? provider,
    String? errorCode,
    dynamic originalError,
  }) {
    return OAuthException(
      type: OAuthErrorType.invalidCredentials,
      message: message,
      provider: provider,
      errorCode: errorCode,
      originalError: originalError,
    );
  }

  /// 서버 에러 생성
  factory OAuthException.serverError({
    required String message,
    String? provider,
    String? errorCode,
    dynamic originalError,
  }) {
    return OAuthException(
      type: OAuthErrorType.serverError,
      message: message,
      provider: provider,
      errorCode: errorCode,
      originalError: originalError,
    );
  }

  /// 토큰 만료 에러 생성
  factory OAuthException.tokenExpired({
    String? provider,
    dynamic originalError,
  }) {
    return OAuthException(
      type: OAuthErrorType.tokenExpired,
      message: '토큰이 만료되었습니다.',
      provider: provider,
      originalError: originalError,
    );
  }

  /// 권한 거부 에러 생성
  factory OAuthException.permissionDenied({
    String? provider,
    dynamic originalError,
  }) {
    return OAuthException(
      type: OAuthErrorType.permissionDenied,
      message: '필요한 권한이 거부되었습니다.',
      provider: provider,
      originalError: originalError,
    );
  }

  /// 알 수 없는 에러 생성
  factory OAuthException.unknown({
    required String message,
    String? provider,
    dynamic originalError,
  }) {
    return OAuthException(
      type: OAuthErrorType.unknown,
      message: message,
      provider: provider,
      originalError: originalError,
    );
  }

  @override
  String toString() {
    return 'OAuthException(type: $type, message: $message, provider: $provider)';
  }
}
