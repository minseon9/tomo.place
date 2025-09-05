import '../entities/auth_token.dart';

abstract class AuthTokenRepository {
  Future<AuthToken?> getCurrentToken();

  Future<void> saveToken(AuthToken token);

  Future<void> clearToken();
}
