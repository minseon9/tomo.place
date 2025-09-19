import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/social_provider.dart';
import '../../data/oauth/oauth_service_factory.dart';
import '../entities/auth_token.dart';
import '../exceptions/oauth_exception.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_token_repository.dart';

class SignupWithSocialUseCase {
  SignupWithSocialUseCase(this._repository, this._tokenRepository, this._container);

  final AuthRepository _repository;
  final AuthTokenRepository _tokenRepository;
  final ProviderContainer _container;

  Future<AuthToken?> execute(SocialProvider provider) async {
    final oauthProvider = OAuthServiceFactory.createProvider(provider, _container);

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
