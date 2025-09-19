import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import '../../../../../shared/config/env_config.dart';

class KakaoOAuthConfig {
  final EnvConfigInterface _envConfig;
  
  KakaoOAuthConfig(this._envConfig);
  
  String get providerId => SocialProvider.kakao.code;
  String get clientId => _envConfig.kakaoClientId;
  String get javascriptKey => _envConfig.kakaoJavascriptKey;
  String get redirectUri => _envConfig.kakaoRedirectUri;
  String get baseUrl => 'https://kauth.kakao.com';
  String get authEndpoint => '/oauth/authorize';
  String get tokenEndpoint => '/oauth/token';
  List<String> get scope => const ['profile_nickname', 'profile_image', 'account_email'];
  
  String get tokenUrl => '$baseUrl$tokenEndpoint';
  String get authUrl => '$baseUrl$authEndpoint';
}
