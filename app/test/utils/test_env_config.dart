import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../lib/shared/config/env_config.dart';

class TestEnvConfig extends EnvConfig {
  static bool _testIsAndroid = false;
  static bool _testIsIOS = false;
  static bool _testInitialized = false;

  /// 테스트용 플랫폼 설정
  static void setTestPlatform({required bool isAndroid, required bool isIOS}) {
    _testIsAndroid = isAndroid;
    _testIsIOS = isIOS;
  }

  /// 테스트용 환경 리셋
  static void resetForTest() {
    _testInitialized = false;
    _testIsAndroid = false;
    _testIsIOS = false;
    dotenv.clean();
  }

  /// 테스트용 초기화 (dotenv.testLoad 사용)
  static Future<void> initializeForTest(String envContent) async {
    if (_testInitialized) return;

    dotenv.testLoad(fileInput: envContent);
    _validateRequiredVariablesForTest();
    _testInitialized = true;
  }

  /// 테스트용 Google Client ID 키 반환
  static String get testGoogleClientIdKey {
    if (_testIsAndroid) {
      return 'ANDROID_GOOGLE_CLIENT_ID';
    } else if (_testIsIOS) {
      return 'IOS_GOOGLE_CLIENT_ID';
    } else {
      throw ArgumentError('Not Supported Platform');
    }
  }

  /// 테스트용 필수 변수 검증
  static void _validateRequiredVariablesForTest() {
    final requiredVars = <String>[
      'API_URL',
      testGoogleClientIdKey,
      'GOOGLE_SERVER_CLIENT_ID',
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
          'Required environment variables are missing: ${missingVars.join(', ')}'
      );
    }
  }

  /// 테스트용 require 메서드
  static String testRequire(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Required environment variable "$key" is not set');
    }
    return value;
  }

  /// 테스트용 getter들 (부모의 static 메서드를 오버라이드할 수 없으므로 새로 정의)
  static String get testApiUrl => testRequire('API_URL');
  static String get testGoogleClientId => testRequire(testGoogleClientIdKey);
  static String get testGoogleServerClientId => testRequire('GOOGLE_SERVER_CLIENT_ID');
  static String get testGoogleRedirectUri => testRequire('GOOGLE_REDIRECT_URI');

  // 선택적 값들
  static String get testAppleClientId => dotenv.env['APPLE_CLIENT_ID'] ?? '';
  static String get testKakaoClientId => dotenv.env['KAKAO_CLIENT_ID'] ?? '';
}
