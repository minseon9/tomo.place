import '../entities/auth_token.dart';

abstract class AuthRepository {
  /// 소셜 로그인 인증
  Future<AuthToken> authenticate({
    required String provider,
    required String authorizationCode,
  });

  /// 토큰 갱신
  Future<AuthToken> refreshToken(String refreshToken);

  /// 로그아웃
  Future<void> logout();
}
