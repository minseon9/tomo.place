import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tomo_place/domains/auth/core/infra/auth_domain_adapter_provider.dart';
import 'package:tomo_place/domains/auth/core/infra/auth_domain_adapter.dart';
import 'package:tomo_place/domains/auth/core/entities/authentication_result.dart';
import 'package:tomo_place/domains/auth/core/entities/auth_token.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/shared/infrastructure/ports/auth_domain_port.dart';

void main() {
  group('authDomainAdapterProvider', () {
    late ProviderContainer container;
    late MockAuthNotifier mockAuthNotifier;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
      container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Provider 생성', () {
      test('authDomainAdapterProvider는 AuthDomainPort를 제공해야 한다', () {
        // Given & When
        final adapter = container.read(authDomainAdapterProvider);

        // Then
        expect(adapter, isNotNull);
        expect(adapter, isA<AuthDomainPort>());
        expect(adapter, isA<AuthDomainAdapter>());
      });

      test('Provider는 동일한 인스턴스를 반환해야 한다 (싱글톤)', () {
        // Given & When
        final adapter1 = container.read(authDomainAdapterProvider);
        final adapter2 = container.read(authDomainAdapterProvider);

        // Then
        expect(adapter1, same(adapter2));
      });
    });

    group('의존성 주입', () {
      test('AuthNotifier에 의존해야 한다', () {
        // Given & When
        final adapter = container.read(authDomainAdapterProvider);

        // Then
        expect(adapter, isNotNull);
        // AuthNotifier는 Provider 생성 시에만 의존성으로 주입됨
        // 실제 호출은 getValidToken() 호출 시에 발생
      });

      test('AuthNotifier의 refreshToken 메서드를 사용해야 한다', () async {
        // Given
        final authToken = AuthToken(
          accessToken: 'test_token',
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken: 'test_refresh_token',
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );
        final authResult = AuthenticationResult.authenticated(authToken);
        
        when(() => mockAuthNotifier.refreshToken(false))
            .thenAnswer((_) async => authResult);

        final adapter = container.read(authDomainAdapterProvider);

        // When
        await adapter.getValidToken();

        // Then
        verify(() => mockAuthNotifier.refreshToken(false)).called(1);
      });
    });

    group('refreshTokenCallback', () {
      test('refreshTokenCallback은 AuthNotifier의 refreshToken을 호출해야 한다', () async {
        // Given
        final authToken = AuthToken(
          accessToken: 'test_token',
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken: 'test_refresh_token',
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );
        final authResult = AuthenticationResult.authenticated(authToken);
        
        when(() => mockAuthNotifier.refreshToken(false))
            .thenAnswer((_) async => authResult);

        final adapter = container.read(authDomainAdapterProvider);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNotNull);
        verify(() => mockAuthNotifier.refreshToken(false)).called(1);
      });

      test('refreshTokenCallback은 false 파라미터로 refreshToken을 호출해야 한다', () async {
        // Given
        final authResult = AuthenticationResult.unauthenticated();
        
        when(() => mockAuthNotifier.refreshToken(false))
            .thenAnswer((_) async => authResult);

        final adapter = container.read(authDomainAdapterProvider);

        // When
        await adapter.getValidToken();

        // Then
        verify(() => mockAuthNotifier.refreshToken(false)).called(1);
        verifyNever(() => mockAuthNotifier.refreshToken(true));
      });

      test('refreshTokenCallback에서 예외가 발생하면 예외를 전파해야 한다', () async {
        // Given
        when(() => mockAuthNotifier.refreshToken(false))
            .thenThrow(Exception('Network error'));

        final adapter = container.read(authDomainAdapterProvider);

        // When & Then
        await expectLater(
          adapter.getValidToken(),
          throwsA(isA<Exception>()),
        );
        verify(() => mockAuthNotifier.refreshToken(false)).called(1);
      });
    });

    group('통합 테스트', () {
      test('전체 플로우가 올바르게 동작해야 한다', () async {
        // Given
        final authToken = AuthToken(
          accessToken: 'integration_test_token',
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken: 'integration_test_refresh_token',
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );
        final authResult = AuthenticationResult.authenticated(authToken);
        
        when(() => mockAuthNotifier.refreshToken(false))
            .thenAnswer((_) async => authResult);

        final adapter = container.read(authDomainAdapterProvider);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNotNull);
        expect(result!.accessToken, equals('integration_test_token'));
        expect(result.accessTokenExpiresAt, equals(authToken.accessTokenExpiresAt));
        expect(result.tokenType, equals(authToken.tokenType));
        verify(() => mockAuthNotifier.refreshToken(false)).called(1);
      });

      test('인증되지 않은 사용자의 경우 null을 반환해야 한다', () async {
        // Given
        final authResult = AuthenticationResult.unauthenticated();
        
        when(() => mockAuthNotifier.refreshToken(false))
            .thenAnswer((_) async => authResult);

        final adapter = container.read(authDomainAdapterProvider);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNull);
        verify(() => mockAuthNotifier.refreshToken(false)).called(1);
      });
    });

    group('Provider 재생성', () {
      test('Provider는 싱글톤이므로 같은 인스턴스를 반환해야 한다', () {
        // Given
        final adapter1 = container.read(authDomainAdapterProvider);

        // When
        final adapter2 = container.read(authDomainAdapterProvider);

        // Then
        expect(adapter1, same(adapter2));
        expect(adapter1, isA<AuthDomainAdapter>());
        expect(adapter2, isA<AuthDomainAdapter>());
      });
    });
  });
}

// Mock 클래스
class MockAuthNotifier extends Mock implements AuthNotifier {
  @override
  Future<AuthenticationResult?> refreshToken(bool force) async {
    return super.noSuchMethod(
      Invocation.method(#refreshToken, [force]),
    );
  }
}
