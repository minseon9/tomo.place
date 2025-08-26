import '../entities/user.dart';
import '../entities/auth_token.dart';
import '../../../social_login/domain/entities/social_account.dart';

/// 인증 관련 데이터 접근을 위한 Repository 인터페이스
/// 
/// 도메인 레이어에서 정의하는 인터페이스로, 구체적인 구현은 데이터 레이어에서 담당합니다.
/// 의존성 역전 원칙에 따라 고수준 모듈(도메인)이 저수준 모듈(데이터)에 의존하지 않습니다.
abstract class AuthRepository {
  /// 소셜 계정 정보로 사용자 인증
  /// 
  /// [socialAccount] 소셜 로그인으로부터 받은 계정 정보
  /// 
  /// Returns: 인증된 사용자 정보
  /// Throws: [AuthException] 인증 실패 시
  Future<User> authenticateWithSocial(SocialAccount socialAccount);

  /// 이메일과 패스워드로 사용자 인증
  /// 
  /// [email] 사용자 이메일
  /// [password] 사용자 패스워드
  /// 
  /// Returns: 인증된 사용자 정보
  /// Throws: [AuthException] 인증 실패 시
  Future<User> authenticateWithEmail(String email, String password);

  /// 이메일로 회원가입
  /// 
  /// [email] 사용자 이메일
  /// [password] 사용자 패스워드
  /// [name] 사용자 이름 (선택사항)
  /// 
  /// Returns: 생성된 사용자 정보
  /// Throws: [AuthException] 회원가입 실패 시
  Future<User> registerWithEmail(String email, String password, {String? name});

  /// 현재 인증된 사용자 정보 조회
  /// 
  /// Returns: 현재 사용자 정보, 인증되지 않은 경우 null
  Future<User?> getCurrentUser();

  /// 인증 토큰 조회
  /// 
  /// Returns: 현재 저장된 인증 토큰, 없는 경우 null
  Future<AuthToken?> getAuthToken();

  /// 토큰 갱신
  /// 
  /// [refreshToken] 갱신 토큰
  /// 
  /// Returns: 새로운 인증 토큰
  /// Throws: [AuthException] 토큰 갱신 실패 시
  Future<AuthToken> refreshToken(String refreshToken);

  /// 로그아웃
  /// 
  /// 로컬에 저장된 토큰과 사용자 정보를 모두 삭제합니다.
  Future<void> logout();

  /// 사용자가 인증되어 있는지 확인
  /// 
  /// Returns: 인증 상태 (true: 인증됨, false: 인증 안됨)
  Future<bool> isAuthenticated();

  /// 비밀번호 재설정 이메일 발송
  /// 
  /// [email] 비밀번호를 재설정할 이메일
  /// 
  /// Throws: [AuthException] 이메일 발송 실패 시
  Future<void> sendPasswordResetEmail(String email);
}

/// 인증 관련 예외 클래스
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}
