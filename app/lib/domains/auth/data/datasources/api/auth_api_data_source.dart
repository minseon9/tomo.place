import '../../../../../../shared/infrastructure/network/api_client.dart';
import '../../models/refresh_token_api_response.dart';
import '../../models/signup_api_response.dart';

abstract class AuthApiDataSource {
  Future<SignupApiResponse> authenticate({
    required String provider,
    required String authorizationCode,
  });
  
  Future<RefreshTokenApiResponse> refreshToken(String refreshToken);
  
  Future<void> logout();
}

class AuthApiDataSourceImpl implements AuthApiDataSource {
  final ApiClient _apiClient;
  
  AuthApiDataSourceImpl(this._apiClient);
  
  @override
  Future<SignupApiResponse> authenticate({
    required String provider,
    required String authorizationCode,
  }) async {
    final response = await _apiClient.post('/api/auth/signup', {
      'provider': provider.toUpperCase(),
      'authorizationCode': authorizationCode,
    }, (json) => SignupApiResponse.fromJson(json));
    
    return response;
  }
  
  @override
  Future<RefreshTokenApiResponse> refreshToken(String refreshToken) async {
    final response = await _apiClient.post('/api/auth/refresh', {
      'refreshToken': refreshToken,
    }, (json) => RefreshTokenApiResponse.fromJson(json));
    
    return response;
  }
  
  @override
  Future<void> logout() async {
    await _apiClient.post('/api/auth/logout', {}, (json) => json);
  }
}
