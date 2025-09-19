import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tomo_place/shared/config/env_config.dart';
import 'google_oauth_config.dart';
import 'apple_oauth_config.dart';
import 'kakao_oauth_config.dart';

class OAuthConfigProvider {
  static final googleOAuthConfigProvider = Provider<GoogleOAuthConfig>((ref) {
    final envConfig = ref.watch(envConfigProvider);
    if (envConfig == null) {
      throw StateError('EnvConfig is not initialized. Call EnvConfig.initialize() first.');
    }
    return GoogleOAuthConfig(envConfig);
  });

  static final appleOAuthConfigProvider = Provider<AppleOAuthConfig>((ref) {
    final envConfig = ref.watch(envConfigProvider);
    if (envConfig == null) {
      throw StateError('EnvConfig is not initialized. Call EnvConfig.initialize() first.');
    }
    return AppleOAuthConfig(envConfig);
  });

  static final kakaoOAuthConfigProvider = Provider<KakaoOAuthConfig>((ref) {
    final envConfig = ref.watch(envConfigProvider);
    if (envConfig == null) {
      throw StateError('EnvConfig is not initialized. Call EnvConfig.initialize() first.');
    }
    return KakaoOAuthConfig(envConfig);
  });
}
