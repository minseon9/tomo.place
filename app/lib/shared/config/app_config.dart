import 'env_config.dart';

class AppConfig {
  static String? _apiUrl;

  static Future<void> initialize() async {
    await EnvConfig.initialize();
  }

  static String get apiUrl => _apiUrl ?? EnvConfig.apiUrl;
}
