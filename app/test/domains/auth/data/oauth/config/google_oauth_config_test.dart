import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/auth/data/oauth/config/google_oauth_config.dart';
import 'package:tomo_place/shared/config/env_config.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';

// Mock EnvConfigInterface
class MockEnvConfigInterface extends Mock implements EnvConfigInterface {}

void main() {
  group('GoogleOAuthConfig', () {
    late MockEnvConfigInterface mockEnvConfig;
    late GoogleOAuthConfig config;

    setUp(() {
      mockEnvConfig = MockEnvConfigInterface();
      when(() => mockEnvConfig.googleClientId).thenReturn('test_google_client_id');
      when(() => mockEnvConfig.googleServerClientId).thenReturn('test_server_client_id');
      when(() => mockEnvConfig.googleRedirectUri).thenReturn('https://test.com/callback');
      
      config = GoogleOAuthConfig(mockEnvConfig);
    });

    group('기본 속성', () {
      test('providerId는 GOOGLE이어야 한다', () {
        expect(config.providerId, equals(SocialProvider.google.code));
      });

      test('clientId는 EnvConfig에서 가져온 값이어야 한다', () {
        expect(config.clientId, equals('test_google_client_id'));
      });

      test('serverClientId는 EnvConfig에서 가져온 값이어야 한다', () {
        expect(config.serverClientId, equals('test_server_client_id'));
      });

      test('redirectUri는 EnvConfig에서 가져온 값이어야 한다', () {
        expect(config.redirectUri, equals('https://test.com/callback'));
      });

      test('baseUrl은 Google OAuth URL이어야 한다', () {
        expect(config.baseUrl, equals('https://accounts.google.com'));
      });

      test('authEndpoint는 올바른 경로여야 한다', () {
        expect(config.authEndpoint, equals('/o/oauth2/v2/auth'));
      });

      test('tokenEndpoint는 올바른 경로여야 한다', () {
        expect(config.tokenEndpoint, equals('/o/oauth2/token'));
      });

      test('scope는 email과 profile을 포함해야 한다', () {
        expect(config.scope, equals(['email', 'profile']));
      });
    });

    group('Google 특화 메서드', () {
      test('tokenUrl은 baseUrl과 tokenEndpoint를 조합한 값이어야 한다', () {
        expect(config.tokenUrl, equals('https://accounts.google.com/o/oauth2/token'));
      });

      test('authUrl은 baseUrl과 authEndpoint를 조합한 값이어야 한다', () {
        expect(config.authUrl, equals('https://accounts.google.com/o/oauth2/v2/auth'));
      });
    });

    group('환경 설정 의존성', () {
      test('EnvConfig가 변경되면 값이 업데이트되어야 한다', () {
        // Given
        when(() => mockEnvConfig.googleClientId).thenReturn('new_client_id');
        when(() => mockEnvConfig.googleServerClientId).thenReturn('new_server_client_id');
        when(() => mockEnvConfig.googleRedirectUri).thenReturn('https://new.com/callback');

        // When
        final newConfig = GoogleOAuthConfig(mockEnvConfig);

        // Then
        expect(newConfig.clientId, equals('new_client_id'));
        expect(newConfig.serverClientId, equals('new_server_client_id'));
        expect(newConfig.redirectUri, equals('https://new.com/callback'));
      });
    });
  });
}
