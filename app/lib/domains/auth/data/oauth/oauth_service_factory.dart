import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/social_provider.dart';
import 'oauth_service.dart';
import 'services/google_auth_service.dart';
import 'config/oauth_config_provider.dart';

class OAuthServiceFactory {
  static final Map<String, OAuthService Function(ProviderContainer)> _providers = {
    SocialProvider.google.code: (container) {
      final config = container.read(OAuthConfigProvider.googleOAuthConfigProvider);
      return GoogleAuthService(config);
    },
    SocialProvider.apple.code: (container) {
      throw ArgumentError('Apple OAuth는 아직 지원되지 않습니다.');
    },
    SocialProvider.kakao.code: (container) {
      throw ArgumentError('Kakao OAuth는 아직 지원되지 않습니다.');
    },
  };

  static OAuthService createProvider(SocialProvider provider, ProviderContainer container) {
    final factory = _providers[provider.code];
    if (factory == null) {
      throw ArgumentError('지원하지 않는 Provider: ${provider.code}');
    }

    final oauthProvider = factory(container);
    if (!oauthProvider.isSupported) {
      throw ArgumentError('Provider ${provider.code}는 현재 플랫폼에서 지원되지 않습니다.');
    }

    return oauthProvider;
  }

  static bool isProviderSupported(SocialProvider provider) {
    return _providers.containsKey(provider.code);
  }
  
}
