import 'package:tomo_place/domains/auth/core/entities/auth_token.dart';
import 'package:tomo_place/domains/auth/core/exceptions/auth_exception.dart';
import 'package:tomo_place/domains/auth/data/models/refresh_token_api_response.dart';
import 'package:tomo_place/domains/auth/data/models/signup_api_response.dart';
import 'package:tomo_place/domains/auth/data/repositories/auth_repository_impl.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/network_exception.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/server_exception.dart';
import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_factory/auth_mock_factory.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late MockAuthApiDataSource mockApiDataSource;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockApiDataSource = AuthMockFactory.createAuthApiDataSource();
      repository = AuthRepositoryImpl(mockApiDataSource);
    });

    group('authenticate', () {
      test('정상적인 인증 요청이 성공해야 한다', () async {
        // Given
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);
        final authorizationCode = faker.guid.guid();
        final signupResponse = SignupApiResponse(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
        );

        when(() => mockApiDataSource.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        )).thenAnswer((_) async => signupResponse);

        // When
        final result = await repository.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        );

        // Then
        expect(result, isA<AuthToken>());
        expect(result.accessToken, equals(signupResponse.accessToken));
        expect(result.refreshToken, equals(signupResponse.refreshToken));
        expect(result.tokenType, equals('Bearer'));
        expect(result.accessTokenExpiresAt, equals(
          DateTime.fromMillisecondsSinceEpoch(signupResponse.accessTokenExpiresAt),
        ));
        expect(result.refreshTokenExpiresAt, equals(
          DateTime.fromMillisecondsSinceEpoch(signupResponse.refreshTokenExpiresAt),
        ));

        verify(() => mockApiDataSource.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        )).called(1);
      });

      test('API 오류 시 AuthException을 던져야 한다', () async {
        // Given
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);
        final authorizationCode = faker.guid.guid();
        final serverException = ServerException.fromStatusCode(
          statusCode: 401,
          message: 'Unauthorized',
        );

        when(() => mockApiDataSource.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        )).thenThrow(serverException);

        // When & Then
        expect(
          () => repository.authenticate(
            provider: provider,
            authorizationCode: authorizationCode,
          ),
          throwsA(isA<AuthException>()),
        );

        verify(() => mockApiDataSource.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        )).called(1);
      });

      test('네트워크 오류 시 AuthException을 던져야 한다', () async {
        // Given
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);
        final authorizationCode = faker.guid.guid();
        final networkException = NetworkException.noConnection();

        when(() => mockApiDataSource.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        )).thenThrow(networkException);

        // When & Then
        expect(
          () => repository.authenticate(
            provider: provider,
            authorizationCode: authorizationCode,
          ),
          throwsA(isA<AuthException>()),
        );

        verify(() => mockApiDataSource.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        )).called(1);
      });

      test('예외 메시지에 원본 오류가 포함되어야 한다', () async {
        // Given
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);
        final authorizationCode = faker.guid.guid();
        final originalException = Exception('Original error');

        when(() => mockApiDataSource.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        )).thenThrow(originalException);

        // When & Then
        try {
          await repository.authenticate(
            provider: provider,
            authorizationCode: authorizationCode,
          );
          fail('Expected AuthException to be thrown');
        } catch (e) {
          expect(e, isA<AuthException>());
          final authException = e as AuthException;
          expect(authException.message, contains('Authentication failed'));
          expect(authException.originalError, equals(originalException));
        }
      });
    });

    group('refreshToken', () {
      test('정상적인 토큰 갱신이 성공해야 한다', () async {
        // Given
        final refreshToken = faker.guid.guid();
        final refreshResponse = RefreshTokenApiResponse(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
        );

        when(() => mockApiDataSource.refreshToken(refreshToken))
            .thenAnswer((_) async => refreshResponse);

        // When
        final result = await repository.refreshToken(refreshToken);

        // Then
        expect(result, isA<AuthToken>());
        expect(result.accessToken, equals(refreshResponse.accessToken));
        expect(result.refreshToken, equals(refreshResponse.refreshToken));
        expect(result.tokenType, equals('Bearer'));
        expect(result.accessTokenExpiresAt, equals(
          DateTime.fromMillisecondsSinceEpoch(refreshResponse.accessTokenExpiresAt),
        ));
        expect(result.refreshTokenExpiresAt, equals(
          DateTime.fromMillisecondsSinceEpoch(refreshResponse.refreshTokenExpiresAt),
        ));

        verify(() => mockApiDataSource.refreshToken(refreshToken)).called(1);
      });

      test('API 오류 시 AuthException을 던져야 한다', () async {
        // Given
        final refreshToken = faker.guid.guid();
        final serverException = ServerException.fromStatusCode(
          statusCode: 401,
          message: 'Token expired',
        );

        when(() => mockApiDataSource.refreshToken(refreshToken))
            .thenThrow(serverException);

        // When & Then
        expect(
          () => repository.refreshToken(refreshToken),
          throwsA(isA<AuthException>()),
        );

        verify(() => mockApiDataSource.refreshToken(refreshToken)).called(1);
      });

      test('네트워크 오류 시 AuthException을 던져야 한다', () async {
        // Given
        final refreshToken = faker.guid.guid();
        final networkException = NetworkException.connectionTimeout();

        when(() => mockApiDataSource.refreshToken(refreshToken))
            .thenThrow(networkException);

        // When & Then
        expect(
          () => repository.refreshToken(refreshToken),
          throwsA(isA<AuthException>()),
        );

        verify(() => mockApiDataSource.refreshToken(refreshToken)).called(1);
      });

      test('예외 메시지에 원본 오류가 포함되어야 한다', () async {
        // Given
        final refreshToken = faker.guid.guid();
        final originalException = Exception('Original error');

        when(() => mockApiDataSource.refreshToken(refreshToken))
            .thenThrow(originalException);

        // When & Then
        try {
          await repository.refreshToken(refreshToken);
          fail('Expected AuthException to be thrown');
        } catch (e) {
          expect(e, isA<AuthException>());
          final authException = e as AuthException;
          expect(authException.message, contains('Failed to refresh token'));
          expect(authException.originalError, equals(originalException));
        }
      });
    });

    group('logout', () {
      test('정상적인 로그아웃이 성공해야 한다', () async {
        // Given
        when(() => mockApiDataSource.logout()).thenAnswer((_) async {});

        // When
        await repository.logout();

        // Then
        verify(() => mockApiDataSource.logout()).called(1);
      });

      test('API 오류 시 예외를 그대로 전파해야 한다', () async {
        // Given
        final serverException = ServerException.fromStatusCode(
          statusCode: 500,
          message: 'Internal server error',
        );

        when(() => mockApiDataSource.logout()).thenThrow(serverException);

        // When & Then
        expect(
          () => repository.logout(),
          throwsA(isA<ServerException>()),
        );

        verify(() => mockApiDataSource.logout()).called(1);
      });

      test('네트워크 오류 시 예외를 그대로 전파해야 한다', () async {
        // Given
        final networkException = NetworkException.noConnection();

        when(() => mockApiDataSource.logout()).thenThrow(networkException);

        // When & Then
        expect(
          () => repository.logout(),
          throwsA(isA<NetworkException>()),
        );

        verify(() => mockApiDataSource.logout()).called(1);
      });
    });
  });
}
