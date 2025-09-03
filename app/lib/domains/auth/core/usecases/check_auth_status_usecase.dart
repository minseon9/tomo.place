import '../entities/auth_token.dart';
import '../repositories/auth_token_repository.dart';

class CheckAuthStatusUseCase {
  final AuthTokenRepository _authTokenRepository;

  CheckAuthStatusUseCase({required AuthTokenRepository authTokenRepository})
    : _authTokenRepository = authTokenRepository;

  Future<bool> execute() async {
    try {
      AuthToken? authToken = await _authTokenRepository.getCurrentToken();

      return authToken?.isAccessTokenValid ?? false;
    } catch (e) {
      return false;
    }
  }
}
