import '../entities/auth_token.dart';

abstract class AuthRepository {
  Future<AuthToken> authenticate({
    required String provider,
    required String authorizationCode,
  });

  Future<AuthToken> refreshToken(String refreshToken);

  Future<void> logout();
}
