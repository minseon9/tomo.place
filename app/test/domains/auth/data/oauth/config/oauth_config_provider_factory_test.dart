import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tomo_place/domains/auth/data/oauth/config/oauth_config_provider.dart';
import 'package:tomo_place/domains/auth/data/oauth/config/google_oauth_config.dart';
import 'package:tomo_place/domains/auth/data/oauth/config/apple_oauth_config.dart';
import 'package:tomo_place/domains/auth/data/oauth/config/kakao_oauth_config.dart';
import 'package:tomo_place/shared/config/env_config.dart';

class MockEnvConfig extends Mock implements EnvConfigInterface {}

void main() {
  group('OAuthConfigProviderFactory', () {
    late MockEnvConfig mockEnvConfig;

    setUp(() {
      mockEnvConfig = MockEnvConfig();
      
      // Mock 환경변수 설정
      when(() => mockEnvConfig.googleClientId).thenReturn('test_google_client_id');
      when(() => mockEnvConfig.googleServerClientId).thenReturn('test_google_server_client_id');
      when(() => mockEnvConfig.googleRedirectUri).thenReturn('https://test.com/callback');
      when(() => mockEnvConfig.appleClientId).thenReturn('test_apple_client_id');
      when(() => mockEnvConfig.appleTeamId).thenReturn('test_apple_team_id');
      when(() => mockEnvConfig.appleKeyId).thenReturn('test_apple_key_id');
      when(() => mockEnvConfig.appleRedirectUri).thenReturn('https://test.com/apple/callback');
      when(() => mockEnvConfig.kakaoClientId).thenReturn('test_kakao_client_id');
      when(() => mockEnvConfig.kakaoJavascriptKey).thenReturn('test_kakao_javascript_key');
      when(() => mockEnvConfig.kakaoRedirectUri).thenReturn('https://test.com/kakao/callback');
    });

    group('googleOAuthConfigProvider', () {
      test('should create GoogleOAuthConfig with valid EnvConfig', () {
        final container = ProviderContainer(
          overrides: [
            envConfigProvider.overrideWith((ref) => mockEnvConfig),
          ],
        );

        final config = container.read(OAuthConfigProvider.googleOAuthConfigProvider);

        expect(config, isA<GoogleOAuthConfig>());
        expect(config.clientId, equals('test_google_client_id'));
        expect(config.serverClientId, equals('test_google_server_client_id'));
        expect(config.redirectUri, equals('https://test.com/callback'));
      });

      test('should throw StateError when EnvConfig is null', () {
        final container = ProviderContainer(
          overrides: [
            envConfigProvider.overrideWith((ref) => null),
          ],
        );

        expect(
          () => container.read(OAuthConfigProvider.googleOAuthConfigProvider),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('appleOAuthConfigProvider', () {
      test('should create AppleOAuthConfig with valid EnvConfig', () {
        final container = ProviderContainer(
          overrides: [
            envConfigProvider.overrideWith((ref) => mockEnvConfig),
          ],
        );

        final config = container.read(OAuthConfigProvider.appleOAuthConfigProvider);

        expect(config, isA<AppleOAuthConfig>());
        expect(config.clientId, equals('test_apple_client_id'));
        expect(config.teamId, equals('test_apple_team_id'));
        expect(config.keyId, equals('test_apple_key_id'));
      });

      test('should throw StateError when EnvConfig is null', () {
        final container = ProviderContainer(
          overrides: [
            envConfigProvider.overrideWith((ref) => null),
          ],
        );

        expect(
          () => container.read(OAuthConfigProvider.appleOAuthConfigProvider),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('kakaoOAuthConfigProvider', () {
      test('should create KakaoOAuthConfig with valid EnvConfig', () {
        final container = ProviderContainer(
          overrides: [
            envConfigProvider.overrideWith((ref) => mockEnvConfig),
          ],
        );

        final config = container.read(OAuthConfigProvider.kakaoOAuthConfigProvider);

        expect(config, isA<KakaoOAuthConfig>());
        expect(config.clientId, equals('test_kakao_client_id'));
        expect(config.javascriptKey, equals('test_kakao_javascript_key'));
        expect(config.redirectUri, equals('https://test.com/kakao/callback'));
      });

      test('should throw StateError when EnvConfig is null', () {
        final container = ProviderContainer(
          overrides: [
            envConfigProvider.overrideWith((ref) => null),
          ],
        );

        expect(
          () => container.read(OAuthConfigProvider.kakaoOAuthConfigProvider),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
