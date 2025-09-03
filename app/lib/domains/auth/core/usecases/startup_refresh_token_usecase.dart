import '../entities/authentication_result.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_token_repository.dart';

class StartupRefreshTokenUseCase {
  StartupRefreshTokenUseCase({
    required AuthRepository repository,
    required AuthTokenRepository tokenRepository,
  }) : _repository = repository,
       _tokenRepository = tokenRepository;

  final AuthRepository _repository;
  final AuthTokenRepository _tokenRepository;

  Future<AuthenticationResult> execute() async {
    try {
      final currentToken = await _tokenRepository.getCurrentToken();
      if (currentToken == null) {
        return AuthenticationResult.unauthenticated();
      }

      if (currentToken.isValid) {
        return AuthenticationResult.authenticated(currentToken);
      }

      // 토큰이 만료되었거나 곧 만료될 예정
      final newToken = await _repository.refreshToken(currentToken.refreshToken);
      await _tokenRepository.saveToken(newToken);

      return AuthenticationResult.authenticated(newToken);
    } catch (e) {
      await _tokenRepository.clearToken();
      return AuthenticationResult.unauthenticated('Token refresh failed: $e');
    }
  }
}
