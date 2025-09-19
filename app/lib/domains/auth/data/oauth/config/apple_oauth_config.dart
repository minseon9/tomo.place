import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import '../../../../../shared/config/env_config.dart';

class AppleOAuthConfig {
  final EnvConfigInterface _envConfig;
  
  AppleOAuthConfig(this._envConfig);
  
  String get providerId => SocialProvider.apple.code;
  String get clientId => _envConfig.appleClientId;
  String get teamId => _envConfig.appleTeamId;
  String get keyId => _envConfig.appleKeyId;
  String get redirectUri => _envConfig.appleRedirectUri;
  String get baseUrl => 'https://appleid.apple.com';
  String get authEndpoint => '/auth/authorize';
  String get tokenEndpoint => '/auth/token';
  List<String> get scope => const ['name', 'email'];
  
  String get tokenUrl => '$baseUrl$tokenEndpoint';
  String get authUrl => '$baseUrl$authEndpoint';
}
