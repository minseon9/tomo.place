import '../entities/auth_token.dart';

/// 인증 관련 데이터 접근을 위한 Repository 인터페이스
/// 
/// 개선된 아키텍처에 따라 단순한 데이터 접근만 담당합니다.
/// 비즈니스 로직은 Service Layer에서 처리합니다.
abstract class AuthRepository {
  /// OAuth 인증 (통합된 회원가입/로그인) - 새로운 방식
  /// 
  /// [provider] OAuth Provider (예: 'google', 'kakao', 'apple')
  /// [authorizationCode] Provider에서 받은 Authorization Code
  ///
  /// Returns: 인증 응답 (토큰 포함)
  /// Throws: [AuthException] 인증 실패 시
  Future<Map<String, dynamic>> authenticate({
    required String provider,
    required String authorizationCode,
  });

  /// 토큰 갱신
  /// 
  /// [refreshToken] 갱신 토큰
  /// Returns: 새로운 인증 토큰
  /// Throws: [AuthException] 토큰 갱신 실패 시
  Future<AuthToken> refreshToken(String refreshToken);

  /// 로그아웃
  /// 
  /// 서버에 로그아웃 요청을 보냅니다.
  Future<void> logout();
}

/// 인증 관련 예외 클래스
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}
