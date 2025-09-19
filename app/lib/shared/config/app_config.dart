import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'env_config.dart';

class AppConfig {
  AppConfig(this._envConfig);

  final EnvConfigInterface _envConfig;
  String? _apiUrl;

  Future<void> initialize() async {
    await _envConfig.initialize();
  }

  String get apiUrl => _apiUrl ?? _envConfig.apiUrl;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  final envConfig = ref.watch(envConfigProvider);
  return AppConfig(envConfig!);
});
