import '../entities/user.dart';
import '../entities/auth_token.dart';

/// 개선된 Auth Repository 인터페이스
/// 
/// 순수한 데이터 접근만 담당하며, 비즈니스 로직은 UseCase에서 처리합니다.
/// 단일 책임 원칙을 준수합니다.
abstract class AuthRepository {
  /// 사용자 인증 (순수한 데이터 접근)
  Future<User> authenticateUser(String provider, String authorizationCode);
  
  /// 사용자 회원가입 (순수한 데이터 접근)
  Future<User> registerUser(String provider, String authorizationCode);
  
  /// 현재 인증된 사용자 조회
  Future<User?> getCurrentUser();
  
  /// 인증 토큰 조회
  Future<AuthToken?> getAuthToken();
  
  /// 토큰 갱신
  Future<AuthToken> refreshToken(String refreshToken);
  
  /// 로그아웃 (데이터 삭제)
  Future<void> logout();
  
  /// 인증 상태 확인
  Future<bool> isAuthenticated();
}
