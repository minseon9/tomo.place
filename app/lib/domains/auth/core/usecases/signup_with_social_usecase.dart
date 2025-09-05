import '../../consts/social_provider.dart';
import '../../data/oauth/oauth_provider_registry.dart';
import '../entities/auth_token.dart';
import '../exceptions/oauth_exception.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_token_repository.dart';

class SignupWithSocialUseCase {
  SignupWithSocialUseCase(this._repository, this._tokenRepository);

  final AuthRepository _repository;
  final AuthTokenRepository _tokenRepository;

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

    final authToken = await _repository.authenticate(
      provider: provider.code,
      authorizationCode: oauthResult.authorizationCode!,
    );

    await _tokenRepository.saveToken(authToken);

    return authToken;
  }
}
