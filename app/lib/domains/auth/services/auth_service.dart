import '../domain/repositories/auth_repository.dart';
import '../presentation/models/login_response.dart';
import '../../../../shared/infrastructure/storage/token_storage_service.dart';
import '../infrastructure/oauth/oauth_provider_registry.dart';
import '../../../../shared/exceptions/oauth_result.dart';
import '../consts/social_provider.dart';
import '../../../../shared/exceptions/oauth_exception.dart';

class AuthService {
  final AuthRepository _repository;
  final TokenStorageService _tokenStorage;
  
  AuthService({
    required AuthRepository repository,
    required TokenStorageService tokenStorage,
  }) : _repository = repository,
       _tokenStorage = tokenStorage;
  
  Future<LoginResponse?> signupWithProvider(SocialProvider provider) async {
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
        errorCode: oauthResult.errorCode,
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

  Future<void> logout() async {
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
  
  Future<bool> refreshToken() async {
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
  
  /// 인증 상태 확인
  Future<bool> isAuthenticated() async {
    try {
      final isValid = await _tokenStorage.isTokenValid();
      return isValid;
    } catch (e) {
      return false;
    }
  }
}
