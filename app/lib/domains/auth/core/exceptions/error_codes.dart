class AuthErrorCodes {
  // 인증 관련
  /// 인증 실패
  static const String authenticationFailed = 'AUTH_001';

  /// 권한 부족
  static const String insufficientPermissions = 'AUTH_002';

  /// 잘못된 인증 정보
  static const String invalidCredentials = 'AUTH_003';

  /// 세션 만료
  static const String sessionExpired = 'AUTH_004';

  // 토큰 관련
  /// 토큰 만료
  static const String tokenExpired = 'AUTH_005';

  /// 토큰 갱신 실패
  static const String tokenRefreshFailed = 'AUTH_006';

  /// 잘못된 토큰
  static const String invalidToken = 'AUTH_007';

  // 계정 관련
  /// 계정 잠김
  static const String accountLocked = 'AUTH_008';

  /// 계정 비활성화
  static const String accountDeactivated = 'AUTH_009';

  // OAuth 관련
  /// OAuth 인증 실패
  static const String oauthAuthenticationFailed = 'AUTH_010';

  /// OAuth 로그아웃 실패
  static const String oauthSignOutFailed = 'AUTH_011';

  /// OAuth 제공자 오류
  static const String oauthProviderError = 'AUTH_012';

  /// OAuth 사용자 취소
  static const String oauthUserCancelled = 'AUTH_013';

  /// OAuth 잘못된 응답
  static const String oauthInvalidResponse = 'AUTH_014';

  /// OAuth 네트워크 오류
  static const String oauthNetworkError = 'AUTH_015';
}
