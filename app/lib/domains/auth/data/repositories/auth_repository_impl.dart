import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_token.dart';
import '../../../../shared/infrastructure/network/api_client.dart';
import '../../../../shared/infrastructure/external_services/oauth_models.dart';

/// AuthRepository 구현체
/// 
/// 개선된 아키텍처에 따라 단순한 데이터 접근만 담당합니다.
/// 공통 ApiClient를 사용하여 서버와 통신합니다.
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  
  AuthRepositoryImpl(this._apiClient);
  
  @override
  Future<Map<String, dynamic>> authenticate(String provider, String code) async {
    try {
      final data = await _apiClient.post(
        '/api/auth/signup',
        {
          'provider': provider,
          'authorizationCode': code,
        },
        (json) => json,
      );
      return data;
    } catch (e) {
      throw AuthException('OAuth 인증에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> authenticateWithOAuth({
    required String provider,
    required String authorizationCode,
  }) async {
    try {
      final data = await _apiClient.post(
        '/api/auth/oauth',
        {
          'provider': provider,
          'authorizationCode': authorizationCode,
        },
        (json) => json,
      );
      return data;
    } catch (e) {
      throw AuthException('OAuth 인증에 실패했습니다: ${e.toString()}');
    }
  }
  
  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    try {
      final data = await _apiClient.post(
        '/api/auth/refresh',
        {
          'refreshToken': refreshToken,
        },
        (json) => AuthToken.fromJson(json),
      );
      return data;
    } catch (e) {
      throw AuthException('토큰 갱신에 실패했습니다: ${e.toString()}');
    }
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
