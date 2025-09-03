import '../repositories/auth_token_repository.dart';

class CheckAuthStatusUseCase {
  final AuthTokenRepository _authTokenRepository;

  CheckAuthStatusUseCase({required AuthTokenRepository authTokenRepository})
    : _authTokenRepository = authTokenRepository;

  Future<bool> execute() async {
    try {
      return await _authTokenRepository.isTokenValid();
    } catch (e) {
      return false;
    }
  }
  
  /// 토큰 상태 상세 조회
  Future<String> getTokenStatus() async {
    try {
      return await _authTokenRepository.getTokenStatus();
    } catch (e) {
      return 'error';
    }
  }
}
