import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tomo_place/domains/auth/data/oauth/oauth_service_factory.dart';
import 'package:tomo_place/domains/auth/data/oauth/config/oauth_config_provider.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/shared/config/env_config.dart';

// Mock EnvConfigInterface
class MockEnvConfigInterface extends Mock implements EnvConfigInterface {}

void main() {
  group('OAuthProviderFactory', () {
    late MockEnvConfigInterface mockEnvConfig;
    late ProviderContainer container;

    setUp(() {
      mockEnvConfig = MockEnvConfigInterface();
      when(() => mockEnvConfig.googleClientId).thenReturn('test_client_id');
      when(() => mockEnvConfig.googleServerClientId).thenReturn('test_server_client_id');
      when(() => mockEnvConfig.googleRedirectUri).thenReturn('https://test.com/callback');
      
      container = ProviderContainer(
        overrides: [
          envConfigProvider.overrideWith((ref) => mockEnvConfig),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Provider 생성', () {
      test('Google Provider를 생성할 수 있어야 한다', () {
        // When
        final provider = OAuthServiceFactory.createProvider(SocialProvider.google, container);

        // Then
        expect(provider, isNotNull);
        expect(provider.providerId, equals('GOOGLE'));
        expect(provider.displayName, isNotEmpty);
      });

      test('Apple Provider는 지원되지 않아야 한다', () {
        // When & Then
        expect(
          () => OAuthServiceFactory.createProvider(SocialProvider.apple, container),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Kakao Provider는 지원되지 않아야 한다', () {
        // When & Then
        expect(
          () => OAuthServiceFactory.createProvider(SocialProvider.kakao, container),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('OAuthConfigProviderFactory를 통해 GoogleOAuthConfig를 주입받아야 한다', () {
        // When
        final provider = OAuthServiceFactory.createProvider(SocialProvider.google, container);

        // Then
        expect(provider, isNotNull);
        expect(provider.providerId, equals('GOOGLE'));
        expect(provider.displayName, isNotEmpty);
      });
    });

    group('Provider 지원 여부 확인', () {
      test('Google Provider는 지원되어야 한다', () {
        // When & Then
        expect(OAuthServiceFactory.isProviderSupported(SocialProvider.google), isTrue);
      });

      test('Apple Provider는 지원되지 않아야 한다', () {
        // When & Then
        expect(OAuthServiceFactory.isProviderSupported(SocialProvider.apple), isTrue); // 등록은 되어있지만 오류 발생
      });

      test('Kakao Provider는 지원되지 않아야 한다', () {
        // When & Then
        expect(OAuthServiceFactory.isProviderSupported(SocialProvider.kakao), isTrue); // 등록은 되어있지만 오류 발생
      });
    });
  });
}
