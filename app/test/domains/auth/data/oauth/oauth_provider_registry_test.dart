import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart';

import 'package:app/domains/auth/data/oauth/oauth_provider_registry.dart';
import 'package:app/domains/auth/data/oauth/oauth_provider.dart';
import 'package:app/domains/auth/data/oauth/oauth_result.dart';
import 'package:app/domains/auth/consts/social_provider.dart';

void main() {
  group('OAuthProviderRegistry', () {
    group('초기화', () {
      test('initialize()가 호출되면 초기화 상태가 true가 되어야 한다', () {
        // Given
        expect(OAuthProviderRegistry.isInitialized, isFalse);

        // When
        OAuthProviderRegistry.initialize();

        // Then
        expect(OAuthProviderRegistry.isInitialized, isTrue);
      });

      test('이미 초기화된 상태에서 initialize()를 다시 호출해도 문제없이 동작해야 한다', () {
        // Given
        OAuthProviderRegistry.initialize();
        expect(OAuthProviderRegistry.isInitialized, isTrue);

        // When & Then
        expect(() => OAuthProviderRegistry.initialize(), returnsNormally);
        expect(OAuthProviderRegistry.isInitialized, isTrue);
      });

      test('초기화 후 Google Provider가 등록되어야 한다', () {
        // Given
        OAuthProviderRegistry.initialize();

        // When
        final provider = OAuthProviderRegistry.createProvider(SocialProvider.google.code);

        // Then
        expect(provider, isNotNull);
        expect(provider.providerId, equals('google'));
      });
    });

    group('Provider 등록', () {
      test('registerProvider()로 커스텀 Provider를 등록할 수 있어야 한다', () {
        // Given
        final customProviderId = faker.lorem.word();
        final mockProvider = TestOAuthProvider();

        // When
        OAuthProviderRegistry.registerProvider(customProviderId, () => mockProvider);

        // Then
        final provider = OAuthProviderRegistry.createProvider(customProviderId);
        expect(provider, equals(mockProvider));
      });

      test('같은 ID로 Provider를 재등록하면 이전 Provider가 덮어써져야 한다', () {
        // Given
        final providerId = faker.lorem.word();
        final firstProvider = TestOAuthProvider();
        final secondProvider = TestOAuthProvider();

        OAuthProviderRegistry.registerProvider(providerId, () => firstProvider);

        // When
        OAuthProviderRegistry.registerProvider(providerId, () => secondProvider);

        // Then
        final provider = OAuthProviderRegistry.createProvider(providerId);
        expect(provider, equals(secondProvider));
        expect(provider, isNot(equals(firstProvider)));
      });
    });

    group('Provider 생성', () {
      test('등록된 Provider ID로 Provider를 생성할 수 있어야 한다', () {
        // Given
        final providerId = faker.lorem.word();
        final mockProvider = TestOAuthProvider();
        OAuthProviderRegistry.registerProvider(providerId, () => mockProvider);

        // When
        final provider = OAuthProviderRegistry.createProvider(providerId);

        // Then
        expect(provider, equals(mockProvider));
      });

      test('등록되지 않은 Provider ID로 생성 시 ArgumentError가 발생해야 한다', () {
        // Given
        final unknownProviderId = faker.lorem.word();

        // When & Then
        expect(
          () => OAuthProviderRegistry.createProvider(unknownProviderId),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('지원되지 않는 플랫폼의 Provider 생성 시 ArgumentError가 발생해야 한다', () {
        // Given
        final providerId = faker.lorem.word();
        final unsupportedProvider = UnsupportedOAuthProvider();
        
        OAuthProviderRegistry.registerProvider(providerId, () => unsupportedProvider);

        // When & Then
        expect(
          () => OAuthProviderRegistry.createProvider(providerId),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Google Provider', () {
      test('Google Provider가 올바르게 등록되어야 한다', () {
        // Given
        OAuthProviderRegistry.initialize();

        // When
        final provider = OAuthProviderRegistry.createProvider(SocialProvider.google.code);

        // Then
        expect(provider.providerId, equals('google'));
        expect(provider.displayName, isNotEmpty);
      });
    });

    group('Apple Provider (TODO)', () {
      test('Apple Provider 등록은 아직 구현되지 않았다', () {
        // Given
        OAuthProviderRegistry.initialize();

        // When & Then
        expect(
          () => OAuthProviderRegistry.createProvider('apple'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Kakao Provider (TODO)', () {
      test('Kakao Provider 등록은 아직 구현되지 않았다', () {
        // Given
        OAuthProviderRegistry.initialize();

        // When & Then
        expect(
          () => OAuthProviderRegistry.createProvider('kakao'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}

// 테스트용 구현 클래스
class TestOAuthProvider implements OAuthProvider {
  @override
  String get providerId => 'test_provider';

  @override
  String get displayName => 'Test Provider';

  @override
  bool get isSupported => true;

  @override
  Future<OAuthResult> signIn() async {
    return OAuthResult.success(authorizationCode: 'test_code');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}

// 지원되지 않는 Provider 테스트용 클래스
class UnsupportedOAuthProvider implements OAuthProvider {
  @override
  String get providerId => 'unsupported_provider';

  @override
  String get displayName => 'Unsupported Provider';

  @override
  bool get isSupported => false;

  @override
  Future<OAuthResult> signIn() async {
    return OAuthResult.success(authorizationCode: 'test_code');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}