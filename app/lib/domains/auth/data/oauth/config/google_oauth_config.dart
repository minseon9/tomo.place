import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import '../../../../../shared/config/env_config.dart';

class GoogleOAuthConfig {
  final EnvConfigInterface _envConfig;
  
  GoogleOAuthConfig(this._envConfig);
  
  String get providerId => SocialProvider.google.code;
  String get clientId => _envConfig.googleClientId;
  String get serverClientId => _envConfig.googleServerClientId;
  String get redirectUri => _envConfig.googleRedirectUri;
  String get baseUrl => 'https://accounts.google.com';
  String get authEndpoint => '/o/oauth2/v2/auth';
  String get tokenEndpoint => '/o/oauth2/token';
  List<String> get scope => const ['email', 'profile'];
  
  String get tokenUrl => '$baseUrl$tokenEndpoint';
  String get authUrl => '$baseUrl$authEndpoint';
}
