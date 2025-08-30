import '../repositories/auth_repository.dart';
import '../../../../shared/infrastructure/storage/token_storage_service.dart';

class LogoutUseCase {
  final AuthRepository _repository;
  final TokenStorageService _tokenStorage;
  
  LogoutUseCase({
    required AuthRepository repository,
    required TokenStorageService tokenStorage,
  }) : _repository = repository,
       _tokenStorage = tokenStorage;
  
  Future<void> execute() async {
    try {
      // 1. 서버에 로그아웃 요청
      await _repository.logout();
    } catch (e) {
      // 서버 요청 실패해도 클라이언트 토큰은 삭제
      print('서버 로그아웃 요청 실패: $e');
    } finally {
      // 2. 로컬 토큰 삭제
      await _tokenStorage.clearTokens();
    }
  }
}
