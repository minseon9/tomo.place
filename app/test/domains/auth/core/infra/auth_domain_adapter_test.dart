import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/domains/auth/core/entities/authentication_result.dart';
import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/core/infra/auth_domain_adapter.dart';
import 'package:app/shared/infrastructure/ports/auth_domain_port.dart';
import 'package:app/shared/infrastructure/ports/auth_token_dto.dart';

void main() {
  group('AuthDomainAdapter', () {
    late AuthDomainAdapter adapter;
    late Future<AuthenticationResult?> Function() mockRefreshTokenCallback;

    setUp(() {
      mockRefreshTokenCallback = MockRefreshTokenCallback();
      adapter = AuthDomainAdapter(mockRefreshTokenCallback);
    });

    group('생성자', () {
      test('refreshTokenCallback을 받아서 생성할 수 있어야 한다', () {
        // Given & When
        final adapter = AuthDomainAdapter(mockRefreshTokenCallback);

        // Then
        expect(adapter, isNotNull);
        expect(adapter, isA<AuthDomainPort>());
      });
    });

    group('AuthDomainPort 구현', () {
      test('AuthDomainPort 인터페이스를 구현해야 한다', () {
        // Given & When & Then
        expect(adapter, isA<AuthDomainPort>());
      });

      test('getValidToken() 메서드를 구현해야 한다', () {
        // Given & When & Then
        expect(adapter.getValidToken, isA<Function>());
      });
    });

    group('getValidToken', () {
      test('인증된 사용자의 유효한 토큰을 반환해야 한다', () async {
        // Given
        final authToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );
        final authResult = AuthenticationResult.authenticated(authToken);
        
        when(() => mockRefreshTokenCallback()).thenAnswer((_) async => authResult);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNotNull);
        expect(result, isA<AuthTokenDto>());
        expect(result!.accessToken, equals(authToken.accessToken));
        expect(result.accessTokenExpiresAt, equals(authToken.accessTokenExpiresAt));
        expect(result.tokenType, equals(authToken.tokenType));
      });

      test('인증되지 않은 사용자의 경우 null을 반환해야 한다', () async {
        // Given
        final authResult = AuthenticationResult.unauthenticated();
        
        when(() => mockRefreshTokenCallback()).thenAnswer((_) async => authResult);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNull);
      });

      test('refreshTokenCallback이 null을 반환하는 경우 null을 반환해야 한다', () async {
        // Given
        when(() => mockRefreshTokenCallback()).thenAnswer((_) async => null);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNull);
      });

      test('refreshTokenCallback에서 예외가 발생하는 경우 예외를 전파해야 한다', () async {
        // Given
        when(() => mockRefreshTokenCallback()).thenThrow(Exception('Network error'));

        // When & Then
        await expectLater(
          adapter.getValidToken(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('토큰 변환', () {
      test('AuthToken을 AuthTokenDto로 올바르게 변환해야 한다', () async {
        // Given
        final authToken = AuthToken(
          accessToken: 'test_access_token',
          accessTokenExpiresAt: DateTime(2024, 1, 1, 12, 0, 0),
          refreshToken: 'test_refresh_token',
          refreshTokenExpiresAt: DateTime(2024, 1, 8, 12, 0, 0),
          tokenType: 'Bearer',
        );
        final authResult = AuthenticationResult.authenticated(authToken);
        
        when(() => mockRefreshTokenCallback()).thenAnswer((_) async => authResult);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNotNull);
        expect(result!.accessToken, equals('test_access_token'));
        expect(result.accessTokenExpiresAt, equals(DateTime(2024, 1, 1, 12, 0, 0)));
        expect(result.tokenType, equals('Bearer'));
      });

      test('다양한 토큰 타입을 올바르게 변환해야 한다', () async {
        // Given
        final authToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 2)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
          tokenType: 'Custom',
        );
        final authResult = AuthenticationResult.authenticated(authToken);
        
        when(() => mockRefreshTokenCallback()).thenAnswer((_) async => authResult);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNotNull);
        expect(result!.tokenType, equals('Custom'));
      });
    });

    group('다양한 시나리오', () {
      test('토큰이 만료된 경우에도 AuthTokenDto를 반환해야 한다 (유효성 검사는 별도)', () async {
        // Given
        final expiredToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: DateTime.now().subtract(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );
        final authResult = AuthenticationResult.authenticated(expiredToken);
        
        when(() => mockRefreshTokenCallback()).thenAnswer((_) async => authResult);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNotNull);
        expect(result!.accessToken, equals(expiredToken.accessToken));
      });

      test('토큰이 곧 만료될 예정인 경우에도 AuthTokenDto를 반환해야 한다 (유효성 검사는 별도)', () async {
        // Given
        final aboutToExpireToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 3)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );
        final authResult = AuthenticationResult.authenticated(aboutToExpireToken);
        
        when(() => mockRefreshTokenCallback()).thenAnswer((_) async => authResult);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNotNull);
        expect(result!.accessToken, equals(aboutToExpireToken.accessToken));
      });

      test('유효한 토큰의 경우 AuthTokenDto를 반환해야 한다', () async {
        // Given
        final validToken = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );
        final authResult = AuthenticationResult.authenticated(validToken);
        
        when(() => mockRefreshTokenCallback()).thenAnswer((_) async => authResult);

        // When
        final result = await adapter.getValidToken();

        // Then
        expect(result, isNotNull);
        expect(result!.accessToken, equals(validToken.accessToken));
        expect(result.accessTokenExpiresAt, equals(validToken.accessTokenExpiresAt));
        expect(result.tokenType, equals(validToken.tokenType));
      });
    });
  });
}

// Mock 클래스
class MockRefreshTokenCallback extends Mock {
  Future<AuthenticationResult?> call();
}