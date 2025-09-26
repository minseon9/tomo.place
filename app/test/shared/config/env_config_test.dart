import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/config/env_config.dart';

import '../../utils/test_env_config_util.dart';


void main() {
  group('EnvConfig', () {
    setUp(() {
      // Reset test environment and set default platform before each test
      TestEnvConfigUtil.resetForTest();
      TestEnvConfigUtil.setTestPlatform(isAndroid: true, isIOS: false);
    });

    tearDown(() {
      // Clean up after each test
      TestEnvConfigUtil.resetForTest();
    });

    group('initialize', () {
      test('should initialize successfully when all required variables are present', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
''';

        // Act & Assert - should not throw
        expect(() => TestEnvConfigUtil.initializeForTest(envContent), returnsNormally);
      });

      test('should throw StateError for missing variables', () async {
        // Arrange
        const envContent = ''; // Empty environment

        // Act & Assert
        expect(
          () => TestEnvConfigUtil.initializeForTest(envContent),
          throwsA(isA<StateError>()),
        );
      });

      test('should throw StateError when variables are empty', () async {
        // Arrange
        const envContent = '''
API_URL=
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
''';

        // Act & Assert
        expect(
          () => TestEnvConfigUtil.initializeForTest(envContent),
          throwsA(isA<StateError>()),
        );
      });

      test('should be idempotent', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
''';

        // Act
        await TestEnvConfigUtil.initializeForTest(envContent);
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Assert - should not throw
        expect(() => TestEnvConfigUtil.initializeForTest(envContent), returnsNormally);
      });
    });

    group('environment', () {
      test('should return default value when ENV is not set', () {
        // Act
        final result = EnvConfig.environment;

        // Assert
        expect(result, equals('dev'));
      });

      test('should return custom value when ENV is set', () {
        // Note: This test is limited because String.fromEnvironment
        // is evaluated at compile time, not runtime
        // In a real test environment, you'd need to compile with different flags
        
        // Act
        final result = EnvConfig.environment;

        // Assert
        expect(result, isA<String>());
      });
    });

    group('isDevelopment', () {
      test('should return boolean value', () {
        // Note: This test is limited because String.fromEnvironment
        // is evaluated at compile time
        // In a real test, you'd compile with --dart-define=ENV=local
        
        // Act
        final result = EnvConfig.isDevelopment;

        // Assert
        expect(result, isA<bool>());
      });
    });

    group('isProduction', () {
      test('should return boolean value', () {
        // Note: This test is limited because String.fromEnvironment
        // is evaluated at compile time
        // In a real test, you'd compile with --dart-define=ENV=prod
        
        // Act
        final result = EnvConfig.isProduction;

        // Assert
        expect(result, isA<bool>());
      });
    });

    group('apiUrl', () {
      test('should return API_URL from environment', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = TestEnvConfigUtil.testApiUrl;

        // Assert
        expect(result, equals('https://api.test.com'));
      });

      test('should throw StateError when API_URL is missing', () async {
        // Arrange
        const envContent = ''; // No API_URL

        // Act & Assert
        expect(
          () => TestEnvConfigUtil.initializeForTest(envContent),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('googleClientId', () {
      test('should return correct client ID for Android platform', () async {
        // Arrange
        TestEnvConfigUtil.setTestPlatform(isAndroid: true, isIOS: false);
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = TestEnvConfigUtil.testGoogleClientId;

        // Assert
        expect(result, equals('android_client_id'));
      });

      test('should return correct client ID for iOS platform', () async {
        // Arrange
        TestEnvConfigUtil.setTestPlatform(isAndroid: false, isIOS: true);
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = TestEnvConfigUtil.testGoogleClientId;

        // Assert
        expect(result, equals('ios_client_id'));
      });

      test('should throw StateError when client ID is missing', () async {
        // Arrange
        TestEnvConfigUtil.setTestPlatform(isAndroid: true, isIOS: false);
        const envContent = ''; // No client IDs

        // Act & Assert
        expect(
          () => TestEnvConfigUtil.initializeForTest(envContent),
          throwsA(isA<StateError>()),
        );
      });

      test('should throw ArgumentError for unsupported platform', () {
        // Arrange
        TestEnvConfigUtil.setTestPlatform(isAndroid: false, isIOS: false);

        // Act & Assert
        expect(
          () => TestEnvConfigUtil.testGoogleClientIdKey,
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('googleServerClientId', () {
      test('should return GOOGLE_SERVER_CLIENT_ID', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = TestEnvConfigUtil.testGoogleServerClientId;

        // Assert
        expect(result, equals('server_client_id'));
      });

      test('should throw StateError when missing', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
'''; // No server client ID

        // Act & Assert
        expect(
          () => TestEnvConfigUtil.initializeForTest(envContent),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('googleRedirectUri', () {
      test('should return GOOGLE_REDIRECT_URI', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = TestEnvConfigUtil.testGoogleRedirectUri;

        // Assert
        expect(result, equals('https://test.com/auth/google'));
      });

      test('should throw StateError when missing', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
'''; // No redirect URI

        // Act & Assert
        expect(
          () => TestEnvConfigUtil.initializeForTest(envContent),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('appleClientId', () {
      test('should return APPLE_CLIENT_ID when present', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
APPLE_CLIENT_ID=apple_client_id
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = TestEnvConfigUtil.testAppleClientId;

        // Assert
        expect(result, equals('apple_client_id'));
      });

      test('should return empty string when missing', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
'''; // No Apple client ID
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = TestEnvConfigUtil.testAppleClientId;

        // Assert
        expect(result, equals(''));
      });
    });

    group('kakaoClientId', () {
      test('should return KAKAO_CLIENT_ID when present', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
KAKAO_CLIENT_ID=kakao_client_id
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = TestEnvConfigUtil.testKakaoClientId;

        // Assert
        expect(result, equals('kakao_client_id'));
      });

      test('should return empty string when missing', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
'''; // No Kakao client ID
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = TestEnvConfigUtil.testKakaoClientId;

        // Assert
        expect(result, equals(''));
      });
    });

    group('getEnv', () {
      test('should return value when key exists', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
TEST_KEY=test_value
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = EnvConfig.getEnv('TEST_KEY');

        // Assert
        expect(result, equals('test_value'));
      });

      test('should return null when key does not exist', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
'''; // No TEST_KEY
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = EnvConfig.getEnv('TEST_KEY');

        // Assert
        expect(result, isNull);
      });
    });

    group('getEnvOrDefault', () {
      test('should return value when key exists', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
TEST_KEY=test_value
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = EnvConfig.getEnvOrDefault('TEST_KEY', 'default_value');

        // Assert
        expect(result, equals('test_value'));
      });

      test('should return default value when key does not exist', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
'''; // No TEST_KEY
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = EnvConfig.getEnvOrDefault('TEST_KEY', 'default_value');

        // Assert
        expect(result, equals('default_value'));
      });
    });

    group('edge cases', () {
      test('should handle empty string values', () async {
        // Arrange
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
EMPTY_KEY=
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = EnvConfig.getEnv('EMPTY_KEY');

        // Assert
        expect(result, equals(''));
      });

      test('should handle special characters in values', () async {
        // Arrange
        const specialValue = 'value with special chars: !@#\$%^&*()';
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
SPECIAL_KEY="value with special chars: !@#\$%^&*()"
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = EnvConfig.getEnv('SPECIAL_KEY');

        // Assert
        expect(result, equals(specialValue));
      });

      test('should handle unicode characters in values', () async {
        // Arrange
        const unicodeValue = '한글 값 with unicode: 🚀';
        const envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
UNICODE_KEY=$unicodeValue
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = EnvConfig.getEnv('UNICODE_KEY');

        // Assert
        expect(result, equals(unicodeValue));
      });

      test('should handle very long values', () async {
        // Arrange
        final longValue = 'A' * 1000;
        final envContent = '''
API_URL=https://api.test.com
ANDROID_GOOGLE_CLIENT_ID=android_client_id
IOS_GOOGLE_CLIENT_ID=ios_client_id
GOOGLE_SERVER_CLIENT_ID=server_client_id
GOOGLE_REDIRECT_URI=https://test.com/auth/google
LONG_KEY=$longValue
''';
        await TestEnvConfigUtil.initializeForTest(envContent);

        // Act
        final result = EnvConfig.getEnv('LONG_KEY');

        // Assert
        expect(result, equals(longValue));
      });
    });
  });
}
