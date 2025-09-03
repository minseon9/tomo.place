import '../../../../shared/infrastructure/storage/token_storage_service.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase({
    required AuthRepository repository,
    required TokenStorageService tokenStorage,
  })  : _repository = repository,
        _tokenStorage = tokenStorage;

  final AuthRepository _repository;
  final TokenStorageService _tokenStorage;

  Future<void> execute() async {
    try {
      await _repository.logout();
    } finally {
      await _tokenStorage.clearTokens();
    }
  }
}



