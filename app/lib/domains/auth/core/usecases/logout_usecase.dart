import '../repositories/auth_repository.dart';
import '../repositories/auth_token_repository.dart';

class LogoutUseCase {
  LogoutUseCase(this._repository, this._tokenRepository);

  final AuthRepository _repository;
  final AuthTokenRepository _tokenRepository;

  Future<void> execute() async {
    try {
      await _repository.logout();
    } finally {
      await _tokenRepository.clearToken();
    }
  }
}
