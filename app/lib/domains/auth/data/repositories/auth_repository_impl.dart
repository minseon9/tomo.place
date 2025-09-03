import '../../core/entities/auth_token.dart';
import '../../core/exceptions/auth_exception.dart';
import '../../core/repositories/auth_repository.dart';
import '../datasources/api/auth_api_data_source.dart';
import '../mappers/auth_token_mapper.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthApiDataSource _apiDataSource;

  AuthRepositoryImpl(this._apiDataSource);

  @override
  Future<AuthToken> authenticate({
    required String provider,
    required String authorizationCode,
  }) async {
    try {
      final response = await _apiDataSource.authenticate(
        provider: provider,
        authorizationCode: authorizationCode,
      );

      return AuthTokenMapper.fromSignupResponse(response);
    } catch (e) {
      throw AuthException.authenticationFailed(
        message: 'Authentication failed: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    try {
      final response = await _apiDataSource.refreshToken(refreshToken);

      return AuthTokenMapper.fromRefreshTokenResponse(response);
    } catch (e) {
      throw AuthException.tokenExpired(
        message: 'Failed to refresh token: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<void> logout() async {
    await _apiDataSource.logout();
  }
}
