import '../../../../shared/exceptions/oauth_exception.dart';
import '../../../../shared/infrastructure/storage/token_storage_service.dart';
import '../../infrastructure/oauth/oauth_provider_registry.dart';
import '../../presentation/models/login_response.dart';
import '../entities/social_provider.dart';
import '../repositories/auth_repository.dart';

class LoginWithSocialUseCase {
  final AuthRepository _repository;
  final TokenStorageService _tokenStorage;
  
  LoginWithSocialUseCase({
    required AuthRepository repository,
    required TokenStorageService tokenStorage,
  }) : _repository = repository,
       _tokenStorage = tokenStorage;
  
  Future<LoginResponse?> execute(SocialProvider provider) async {
    OAuthProviderRegistry.initialize();
    
    final oauthProvider = OAuthProviderRegistry.createProvider(provider.code);
    
    final oauthResult = await oauthProvider.signIn();
    
    // 사용자가 취소한 경우 예외를 던지지 않고 null 반환
    if (oauthResult.cancelled) {
      return null;
    }
    
    if (!oauthResult.success) {
      throw OAuthException.authenticationFailed(
        message: 'OAuth authentication failed: ${oauthResult.error}',
        provider: provider.code,
      );
    }
    
    // Repository와 GoogleAuthProvider에서 이미 적절한 예외를 던지므로 
    // 추가 래핑 없이 그대로 전파
    final responseData = await _repository.authenticate(
      provider: provider.code,
      authorizationCode: oauthResult.authorizationCode!,
    );
    
    final loginResponse = LoginResponse.fromJson(responseData);
    
    await _tokenStorage.saveTokens(
      accessToken: loginResponse.token,
      refreshToken: loginResponse.refreshToken,
    );
    
    return loginResponse;
  }
}
