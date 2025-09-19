import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class EnvConfigInterface {
  Future<void> initialize();
  String get apiUrl;
}

class EnvConfigImpl implements EnvConfigInterface {
  @override
  Future<void> initialize() async {
    await EnvConfig.initialize();
  }

  @override
  String get apiUrl => EnvConfig.apiUrl;
}

class EnvConfig {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const environment = String.fromEnvironment('ENV', defaultValue: 'dev');

    await dotenv.load(fileName: 'assets/env/.env.$environment');

    _isInitialized = true;
  }

  static String get _googleClientIdKey {
    if (Platform.isAndroid) {
      return 'ANDROID_GOOGLE_CLIENT_ID';
    } else if (Platform.isIOS) {
      return 'IOS_GOOGLE_CLIENT_ID';
    } else {
      throw ArgumentError('Not Supported Platform');
    }
  }


  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Required environment variable "$key" is not set\n'
        'Please check your .env.$environment file.',
      );
    }
    return value;
  }

  static String get environment =>
      const String.fromEnvironment('ENV', defaultValue: 'dev');

  static bool get isDevelopment =>
      environment == 'local' || environment == 'dev';

  static bool get isProduction => environment == 'prod';

  static String get apiUrl => _require('API_URL');

  static String get googleClientId => _require(_googleClientIdKey);

  static String get googleServerClientId => _require('GOOGLE_SERVER_CLIENT_ID');

  static String get googleRedirectUri => _require('GOOGLE_REDIRECT_URI');

  static String get appleClientId => dotenv.env['APPLE_CLIENT_ID'] ?? '';

  static String get appleTeamId => dotenv.env['APPLE_TEAM_ID'] ?? '';

  static String get appleKeyId => dotenv.env['APPLE_KEY_ID'] ?? '';

  static String get appleRedirectUri => dotenv.env['APPLE_REDIRECT_URI'] ?? '';

  static String get kakaoClientId => dotenv.env['KAKAO_CLIENT_ID'] ?? '';

  static String get kakaoJavascriptKey =>
      dotenv.env['KAKAO_JAVASCRIPT_KEY'] ?? '';

  static String get kakaoRedirectUri => dotenv.env['KAKAO_REDIRECT_URI'] ?? '';

  static String? getEnv(String key) => dotenv.env[key];

  static String getEnvOrDefault(String key, String defaultValue) =>
      dotenv.env[key] ?? defaultValue;
}

final envConfigProvider = StateProvider<EnvConfigInterface?>((ref) => null);
