import '../entities/authentication_result.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_token_repository.dart';

class RefreshTokenUseCase {
  RefreshTokenUseCase(this._authRepository, this._tokenRepository);

  final AuthRepository _authRepository;
  final AuthTokenRepository _tokenRepository;

  Future<AuthenticationResult> execute() async {
    try {
      final currentToken = await _tokenRepository.getCurrentToken();
      if (currentToken == null) {
        return AuthenticationResult.unauthenticated();
      }

      if (currentToken.isRefreshTokenValid) {
        return AuthenticationResult.authenticated(currentToken);
      }

      final newToken = await _authRepository.refreshToken(
        currentToken.refreshToken,
      );
      await _tokenRepository.saveToken(newToken);

      return AuthenticationResult.authenticated(newToken);
    } catch (e) {
      await _tokenRepository.clearToken();
      return AuthenticationResult.unauthenticated('Token refresh failed: $e');
    }
  }
}
