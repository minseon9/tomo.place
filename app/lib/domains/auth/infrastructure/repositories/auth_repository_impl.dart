import '../../core/repositories/auth_repository.dart';
import '../../core/entities/auth_token.dart';
import '../../../../shared/infrastructure/network/api_client.dart';

/// AuthRepository 구현체
/// 
/// 개선된 아키텍처에 따라 단순한 데이터 접근만 담당합니다.
/// 공통 ApiClient를 사용하여 서버와 통신합니다.
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  
  AuthRepositoryImpl(this._apiClient);
  
  @override
  Future<Map<String, dynamic>> authenticate({
    required String provider,
    required String authorizationCode,
  }) async {
    // ApiClient에서 이미 적절한 예외 변환을 하므로 그대로 전파
    final data = await _apiClient.post(
      '/api/auth/signup',
      {
        'provider': provider.toUpperCase(),
        'authorizationCode': authorizationCode,
      },
      (json) => json,
    );
    return data;
  }
  
  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    // ApiClient에서 이미 적절한 예외 변환을 하므로 그대로 전파
    final data = await _apiClient.post(
      '/api/auth/refresh',
      {
        'refreshToken': refreshToken,
      },
      (json) => AuthToken.fromJson(json),
    );
    return data;
  }
  
  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(
        '/api/auth/logout',
        {},
        (json) => json,
      );
    } catch (e) {
      // 로그아웃 실패해도 예외를 던지지 않음
      // 클라이언트에서 토큰을 삭제하면 됨
      print('로그아웃 요청 실패: $e');
    }
  }
}
