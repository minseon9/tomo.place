import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tomo_place/shared/config/env_config.dart';

import 'google_oauth_config.dart';

final googleOAuthConfigProvider = Provider<GoogleOAuthConfig>((ref) {
  final envConfig = ref.watch(envConfigProvider);
  if (envConfig == null) {
    throw StateError('EnvConfig is not initialized. Call EnvConfig.initialize() first.');
  }
  return GoogleOAuthConfig(envConfig);
});
