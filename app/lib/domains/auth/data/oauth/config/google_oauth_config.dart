import 'package:tomo_place/domains/auth/consts/social_provider.dart';

import '../../../../../shared/config/env_config.dart';

class GoogleOAuthConfig {
  static const String baseUrl = 'https://accounts.google.com';

  static const String authEndpoint = '/o/oauth2/v2/auth';

  static const String tokenEndpoint = '/o/oauth2/token';

  static const List<String> defaultScope = ['email', 'profile'];

  static String get clientId => EnvConfig.googleClientId;

  static String get serverClientId => EnvConfig.googleServerClientId;

  static String get redirectUri => EnvConfig.googleRedirectUri;

  static OAuthProviderConfig get defaultConfig => OAuthProviderConfig(
    providerId: SocialProvider.google.code,
    clientId: clientId,
    serverClientId: serverClientId,
    baseUrl: baseUrl,
    authEndpoint: authEndpoint,
    tokenEndpoint: tokenEndpoint,
    scope: defaultScope,
    redirectUri: redirectUri,
  );
}

class OAuthProviderConfig {
  final String providerId;
  final String clientId;
  final String? serverClientId;
  final String baseUrl;
  final String authEndpoint;
  final String tokenEndpoint;
  final List<String> scope;
  final String redirectUri;

  const OAuthProviderConfig({
    required this.providerId,
    required this.clientId,
    this.serverClientId,
    required this.baseUrl,
    required this.authEndpoint,
    required this.tokenEndpoint,
    required this.scope,
    required this.redirectUri,
  });

  String get tokenUrl => '$baseUrl$tokenEndpoint';
}
