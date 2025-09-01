import '../../../../shared/infrastructure/storage/token_storage_service.dart';

class CheckAuthStatusUseCase {
  final TokenStorageService _tokenStorage;
  
  CheckAuthStatusUseCase({
    required TokenStorageService tokenStorage,
  }) : _tokenStorage = tokenStorage;
  
  /// 인증 상태 확인
  Future<bool> execute() async {
    try {
      final isValid = await _tokenStorage.isTokenValid();
      return isValid;
    } catch (e) {
      return false;
    }
  }
}
