import '../../../consts/social_provider.dart';
import 'apple_oauth_config.dart';
import 'google_oauth_config.dart';
import 'kakao_oauth_config.dart';

class OAuthConfig {
  static final Map<String, OAuthProviderConfig> _providerConfigs = {
    SocialProvider.google.code: GoogleOAuthConfig.defaultConfig,
    SocialProvider.apple.code: AppleOAuthConfig.defaultConfig,
    SocialProvider.kakao.code: KakaoOAuthConfig.defaultConfig,
  };

  static OAuthProviderConfig? getProviderConfig(String provider) {
    return _providerConfigs[provider.toUpperCase()];
  }

  static OAuthProviderConfig? getConfigByProvider(SocialProvider provider) {
    return getProviderConfig(provider.code);
  }

  static List<String> get supportedProviders => _providerConfigs.keys.toList();

  static bool isProviderSupported(String provider) {
    return _providerConfigs.containsKey(provider.toUpperCase());
  }

  static OAuthProviderConfig get googleConfig =>
      GoogleOAuthConfig.defaultConfig;

  static OAuthProviderConfig get appleConfig => AppleOAuthConfig.defaultConfig;

  static OAuthProviderConfig get kakaoConfig => KakaoOAuthConfig.defaultConfig;

  static void updateProviderConfig(
    String provider,
    OAuthProviderConfig config,
  ) {
    _providerConfigs[provider.toUpperCase()] = config;
  }

  static void refreshConfigs() {
    _providerConfigs['GOOGLE'] = GoogleOAuthConfig.defaultConfig;
    _providerConfigs['APPLE'] = AppleOAuthConfig.defaultConfig;
    _providerConfigs['KAKAO'] = KakaoOAuthConfig.defaultConfig;
  }
}
