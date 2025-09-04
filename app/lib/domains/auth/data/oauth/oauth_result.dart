class OAuthResult {
  final bool success;
  final bool cancelled;
  final String? authorizationCode;
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
  factory OAuthResult.success({required String authorizationCode}) {
    return OAuthResult(success: true, authorizationCode: authorizationCode);
  }

  factory OAuthResult.failure({required String error, String? errorCode}) {
    return OAuthResult(success: false, error: error, errorCode: errorCode);
  }

  factory OAuthResult.cancelled() {
    return const OAuthResult(
      success: false,
      cancelled: true,
      error: 'User cancelled authentication',
      errorCode: 'USER_CANCELLED',
    );
  }
}
