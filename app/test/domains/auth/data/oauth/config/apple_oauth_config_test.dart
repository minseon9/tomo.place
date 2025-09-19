import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/auth/data/oauth/config/apple_oauth_config.dart';
import 'package:tomo_place/shared/config/env_config.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';

// Mock EnvConfigInterface
class MockEnvConfigInterface extends Mock implements EnvConfigInterface {}

void main() {
  group('AppleOAuthConfig', () {
    late MockEnvConfigInterface mockEnvConfig;
    late AppleOAuthConfig config;

    setUp(() {
      mockEnvConfig = MockEnvConfigInterface();
      when(() => mockEnvConfig.appleClientId).thenReturn('test_apple_client_id');
      when(() => mockEnvConfig.appleTeamId).thenReturn('test_team_id');
      when(() => mockEnvConfig.appleKeyId).thenReturn('test_key_id');
      when(() => mockEnvConfig.appleRedirectUri).thenReturn('https://test.com/callback');
      
      config = AppleOAuthConfig(mockEnvConfig);
    });

    group('기본 속성', () {
      test('providerId는 APPLE이어야 한다', () {
        expect(config.providerId, equals(SocialProvider.apple.code));
      });

      test('clientId는 EnvConfig에서 가져온 값이어야 한다', () {
        expect(config.clientId, equals('test_apple_client_id'));
      });

      test('teamId는 EnvConfig에서 가져온 값이어야 한다', () {
        expect(config.teamId, equals('test_team_id'));
      });

      test('keyId는 EnvConfig에서 가져온 값이어야 한다', () {
        expect(config.keyId, equals('test_key_id'));
      });

      test('redirectUri는 EnvConfig에서 가져온 값이어야 한다', () {
        expect(config.redirectUri, equals('https://test.com/callback'));
      });

      test('baseUrl은 Apple OAuth URL이어야 한다', () {
        expect(config.baseUrl, equals('https://appleid.apple.com'));
      });

      test('authEndpoint는 올바른 경로여야 한다', () {
        expect(config.authEndpoint, equals('/auth/authorize'));
      });

      test('tokenEndpoint는 올바른 경로여야 한다', () {
        expect(config.tokenEndpoint, equals('/auth/token'));
      });

      test('scope는 name과 email을 포함해야 한다', () {
        expect(config.scope, equals(['name', 'email']));
      });
    });

    group('Apple 특화 메서드', () {
      test('tokenUrl은 baseUrl과 tokenEndpoint를 조합한 값이어야 한다', () {
        expect(config.tokenUrl, equals('https://appleid.apple.com/auth/token'));
      });

      test('authUrl은 baseUrl과 authEndpoint를 조합한 값이어야 한다', () {
        expect(config.authUrl, equals('https://appleid.apple.com/auth/authorize'));
      });
    });

    group('기본값 처리', () {
      test('clientId가 비어있으면 기본값을 사용해야 한다', () {
        // Given
        when(() => mockEnvConfig.appleClientId).thenReturn('');
        when(() => mockEnvConfig.appleTeamId).thenReturn('');
        when(() => mockEnvConfig.appleKeyId).thenReturn('');
        when(() => mockEnvConfig.appleRedirectUri).thenReturn('');

        // When
        final configWithDefaults = AppleOAuthConfig(mockEnvConfig);

        // Then
        expect(configWithDefaults.clientId, equals('com.example.app'));
        expect(configWithDefaults.teamId, equals(''));
        expect(configWithDefaults.keyId, equals(''));
        expect(configWithDefaults.redirectUri, equals('https://example.com/auth/apple/callback'));
      });
    });

    group('환경 설정 의존성', () {
      test('EnvConfig가 변경되면 값이 업데이트되어야 한다', () {
        // Given
        when(() => mockEnvConfig.appleClientId).thenReturn('new_client_id');
        when(() => mockEnvConfig.appleTeamId).thenReturn('new_team_id');
        when(() => mockEnvConfig.appleKeyId).thenReturn('new_key_id');
        when(() => mockEnvConfig.appleRedirectUri).thenReturn('https://new.com/callback');

        // When
        final newConfig = AppleOAuthConfig(mockEnvConfig);

        // Then
        expect(newConfig.clientId, equals('new_client_id'));
        expect(newConfig.teamId, equals('new_team_id'));
        expect(newConfig.keyId, equals('new_key_id'));
        expect(newConfig.redirectUri, equals('https://new.com/callback'));
      });
    });
  });
}
