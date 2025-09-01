import '../repositories/auth_repository.dart';
import '../../../../shared/infrastructure/storage/token_storage_service.dart';

class RefreshTokenUseCase {
  final AuthRepository _repository;
  final TokenStorageService _tokenStorage;
  
  RefreshTokenUseCase({
    required AuthRepository repository,
    required TokenStorageService tokenStorage,
  }) : _repository = repository,
       _tokenStorage = tokenStorage;
  
  Future<bool> execute() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }
      
      // 서버에 토큰 갱신 요청
      final newTokens = await _repository.refreshToken(refreshToken);
      
      // 새 토큰 저장
      await _tokenStorage.saveTokens(
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken,
      );
      
      return true;
    } catch (e) {
      // 토큰 갱신 실패 시 기존 토큰 삭제
      await _tokenStorage.clearTokens();
      return false;
    }
  }
}
