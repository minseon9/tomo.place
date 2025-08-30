import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static bool _isInitialized = false;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    const environment = String.fromEnvironment('ENV', defaultValue: 'dev');

    await dotenv.load(fileName: 'assets/env/.env.$environment');
    
    _validateRequiredVariables();

    _isInitialized = true;
  }
  
  /// 플랫폼별 Google Client ID 키 결정
  static String get _googleClientIdKey {
    if (Platform.isAndroid) {
      return 'ANDROID_GOOGLE_CLIENT_ID';
    } else if (Platform.isIOS) {
      return 'IOS_GOOGLE_CLIENT_ID';
    } else {
      throw ArgumentError('Not Supported Platform');
    }
  }

  /// 플랫폼별 Google Server Client ID 키 결정
  static String get _googleServerClientIdKey {
    if (Platform.isAndroid) {
      return 'ANDROID_GOOGLE_SERVER_CLIENT_ID';
    } else if (Platform.isIOS) {
      return 'IOS_GOOGLE_SERVER_CLIENT_ID';
    } else {
      throw ArgumentError('Not Supported Platform');
    }
  }

  /// 필수 환경 변수 검증
  static void _validateRequiredVariables() {
    final requiredVars = <String>[
      'API_URL',
      _googleClientIdKey,
      _googleServerClientIdKey,
      'GOOGLE_REDIRECT_URI',
    ];

    final missingVars = <String>[];

    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        missingVars.add(varName);
      }
    }

    if (missingVars.isNotEmpty) {
      throw StateError(
        'Required environment variables are missing: ${missingVars.join(', ')}\n'
        'Please check your .env.${environment} file.',
      );
    }
  }

  /// 필수 환경 변수 조회 (없으면 에러)
  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Required environment variable "$key" is not set');
    }
    return value;
  }
  
  /// 현재 환경 이름
  static String get environment => 
      const String.fromEnvironment('ENV', defaultValue: 'dev');
  
  /// 개발 환경 여부
  static bool get isDevelopment => environment == 'local' || environment == 'dev';
  
  /// 프로덕션 환경 여부
  static bool get isProduction => environment == 'prod';
  
  /// API URL (필수)
  static String get apiUrl => _require('API_URL');
  
  /// Google OAuth 설정 (플랫폼별, 필수)
  static String get googleClientId => _require(_googleClientIdKey);
      
  static String get googleServerClientId => _require(_googleServerClientIdKey);
      
  static String get googleRedirectUri => _require('GOOGLE_REDIRECT_URI');
  
  /// Apple OAuth 설정 (iOS만, 선택적)
  static String get appleClientId => 
      dotenv.env['APPLE_CLIENT_ID'] ?? '';
      
  static String get appleTeamId => 
      dotenv.env['APPLE_TEAM_ID'] ?? '';
      
  static String get appleKeyId => 
      dotenv.env['APPLE_KEY_ID'] ?? '';
      
  static String get appleRedirectUri => 
      dotenv.env['APPLE_REDIRECT_URI'] ?? '';
  
  /// Kakao OAuth 설정 (선택적)
  static String get kakaoClientId => 
      dotenv.env['KAKAO_CLIENT_ID'] ?? '';
      
  static String get kakaoJavascriptKey => 
      dotenv.env['KAKAO_JAVASCRIPT_KEY'] ?? '';
      
  static String get kakaoRedirectUri => 
      dotenv.env['KAKAO_REDIRECT_URI'] ?? '';
  
  /// 환경 변수 직접 조회
  static String? getEnv(String key) => dotenv.env[key];
  
  /// 환경 변수 조회 (기본값 포함)
  static String getEnvOrDefault(String key, String defaultValue) => 
      dotenv.env[key] ?? defaultValue;
}
