import '../../../../shared/infrastructure/storage/access_token_memory_store.dart';
import '../../../../shared/infrastructure/storage/token_storage_service.dart';
import '../../consts/social_provider.dart';
import '../../data/oauth/oauth_provider_registry.dart';
import '../entities/auth_token.dart';
import '../exceptions/oauth_exception.dart';
import '../repositories/auth_repository.dart';

class SignupWithSocialUseCase {
  SignupWithSocialUseCase({
    required AuthRepository repository,
    required TokenStorageService tokenStorage,
    required AccessTokenMemoryStore memoryStore,
  }) : _repository = repository,
       _tokenStorage = tokenStorage,
       _memoryStore = memoryStore;

  final AuthRepository _repository;
  final TokenStorageService _tokenStorage;
  final AccessTokenMemoryStore _memoryStore;

  Future<AuthToken?> execute(SocialProvider provider) async {
    OAuthProviderRegistry.initialize();

    final oauthProvider = OAuthProviderRegistry.createProvider(provider.code);

    final oauthResult = await oauthProvider.signIn();
    if (oauthResult.cancelled) {
      return null;
    }

    if (!oauthResult.success) {
      throw OAuthException.authenticationFailed(
        message: 'OAuth authentication failed: ${oauthResult.error}',
        provider: provider.code,
      );
    }

    final response = await _repository.authenticate(
      provider: provider.code,
      authorizationCode: oauthResult.authorizationCode!,
    );

    await _tokenStorage.saveRefreshToken(
      refreshToken: response.refreshToken,
      refreshTokenExpiresAt: response.refreshTokenExpiresAt,
    );
    _memoryStore.set(response.accessToken, response.accessTokenExpiresAt);

    return response;
  }
}
