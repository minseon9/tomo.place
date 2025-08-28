import '../entities/user.dart';

/// 인증 관련 데이터 접근을 위한 Repository 인터페이스
/// 
/// 개선된 아키텍처에 따라 단순한 데이터 접근만 담당합니다.
/// 비즈니스 로직은 Service Layer에서 처리합니다.
abstract class AuthRepository {
  /// OAuth 인증
  /// 
  /// [provider] OAuth Provider (예: 'GOOGLE', 'KAKAO', 'APPLE')
  /// [code] OAuth 인증 코드
  /// 
  /// Returns: 인증된 사용자 정보
  /// Throws: [AuthException] 인증 실패 시
  Future<User> authenticate(String provider, String code);

  /// OAuth 회원가입
  /// 
  /// [provider] OAuth Provider (예: 'GOOGLE', 'KAKAO', 'APPLE')
  /// [code] OAuth 인증 코드
  /// 
  /// Returns: 생성된 사용자 정보
  /// Throws: [AuthException] 회원가입 실패 시
  Future<User> register(String provider, String code);

  /// 현재 인증된 사용자 정보 조회
  /// 
  /// Returns: 현재 사용자 정보, 인증되지 않은 경우 null
  Future<User?> getCurrentUser();

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
