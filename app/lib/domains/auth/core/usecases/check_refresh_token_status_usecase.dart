import '../../../../shared/infrastructure/storage/token_storage_service.dart';

class CheckRefreshTokenStatusUseCase {
  final TokenStorageService _tokenStorage;

  CheckRefreshTokenStatusUseCase({required TokenStorageService tokenStorage})
    : _tokenStorage = tokenStorage;

  Future<bool> execute() async {
    try {
      final expiry = await _tokenStorage.getRefreshTokenExpiry();
      if (expiry != null && DateTime.now().isAfter(expiry)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
