import '../entities/auth_token.dart';

abstract class AuthTokenRepository {
  /// 현재 저장된 인증 토큰 조회
  Future<AuthToken?> getCurrentToken();
  
  /// 토큰 저장
  Future<void> saveToken(AuthToken token);
  
  /// 토큰 삭제
  Future<void> clearToken();
  
  /// 토큰 유효성 확인
  Future<bool> isTokenValid();
  
  /// 토큰 상태 조회
  Future<String> getTokenStatus();
}
