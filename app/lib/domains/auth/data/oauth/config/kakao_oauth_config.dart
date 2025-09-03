import 'package:app/domains/auth/consts/social_provider.dart';

import '../../../../../shared/config/env_config.dart';
import 'google_oauth_config.dart'; // OAuthProviderConfig 모델 사용

class KakaoOAuthConfig {
  static const String baseUrl = 'https://kauth.kakao.com';

  static const String authEndpoint = '/oauth/authorize';

  static const String tokenEndpoint = '/oauth/token';

  static const String defaultScope =
      'profile_nickname profile_image account_email';

  static String get clientId => EnvConfig.kakaoClientId;

  static String get javascriptKey => EnvConfig.kakaoJavascriptKey;

  static String get redirectUri => EnvConfig.kakaoRedirectUri;

  static OAuthProviderConfig get defaultConfig => OAuthProviderConfig(
    providerId: SocialProvider.kakao.code,
    clientId: clientId,
    baseUrl: baseUrl,
    authEndpoint: authEndpoint,
    tokenEndpoint: tokenEndpoint,
    scope: defaultScope,
    redirectUri: redirectUri,
  );
}
