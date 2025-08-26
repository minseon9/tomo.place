import '../entities/social_account.dart';

/// 소셜 로그인 관련 데이터 접근을 위한 Repository 인터페이스
/// 
/// 각 소셜 플랫폼의 인증을 추상화한 인터페이스입니다.
/// 구체적인 SDK 구현은 데이터 레이어에서 담당합니다.
abstract class SocialAuthRepository {
  /// 카카오 로그인
  /// 
  /// Returns: 카카오 계정 정보
  /// Throws: [SocialLoginException] 로그인 실패 시
  Future<SocialAccount> loginWithKakao();

  /// 구글 로그인
  /// 
  /// Returns: 구글 계정 정보
  /// Throws: [SocialLoginException] 로그인 실패 시
  Future<SocialAccount> loginWithGoogle();

  /// 애플 로그인
  /// 
  /// Returns: 애플 계정 정보
  /// Throws: [SocialLoginException] 로그인 실패 시
  Future<SocialAccount> loginWithApple();

  /// 특정 제공자의 로그아웃
  /// 
  /// [provider] 로그아웃할 소셜 제공자 ('kakao', 'google', 'apple')
  Future<void> logout(String provider);

  /// 특정 제공자가 현재 기기에서 로그인 가능한지 확인
  /// 
  /// [provider] 확인할 소셜 제공자
  /// 
  /// Returns: 로그인 가능 여부
  Future<bool> isAvailable(String provider);

  /// 제공자별 추가 권한 요청
  /// 
  /// [provider] 소셜 제공자
  /// [scopes] 요청할 권한 목록
  /// 
  /// Returns: 권한이 부여된 계정 정보
  /// Throws: [SocialLoginException] 권한 요청 실패 시
  Future<SocialAccount> requestAdditionalScopes(
    String provider, 
    List<String> scopes,
  );
}

/// 소셜 로그인 관련 예외 클래스
class SocialLoginException implements Exception {
  const SocialLoginException(
    this.message, {
    this.provider,
    this.code,
    this.originalException,
  });

  final String message;
  final String? provider;
  final String? code;
  final dynamic originalException;

  @override
  String toString() {
    return 'SocialLoginException: $message'
        '${provider != null ? ' (provider: $provider)' : ''}'
        '${code != null ? ' (code: $code)' : ''}';
  }
}
