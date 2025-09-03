import 'package:app/domains/auth/consts/social_provider.dart';

import '../../../../../shared/config/env_config.dart';
import 'google_oauth_config.dart'; // OAuthProviderConfig 모델 사용

class AppleOAuthConfig {
  static const String baseUrl = 'https://appleid.apple.com';

  static const String authEndpoint = '/auth/authorize';

  static const String tokenEndpoint = '/auth/token';

  static const String defaultScope = 'name email';

  static String get clientId => EnvConfig.appleClientId;

  static String get teamId => EnvConfig.appleTeamId;

  static String get keyId => EnvConfig.appleKeyId;

  static String get redirectUri => EnvConfig.appleRedirectUri;

  static OAuthProviderConfig get defaultConfig => OAuthProviderConfig(
    providerId: SocialProvider.apple.code,
    clientId: clientId,
    baseUrl: baseUrl,
    authEndpoint: authEndpoint,
    tokenEndpoint: tokenEndpoint,
    scope: defaultScope,
    redirectUri: redirectUri,
  );
}
