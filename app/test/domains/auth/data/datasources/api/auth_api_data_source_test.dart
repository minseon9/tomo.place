import 'package:tomo_place/domains/auth/data/models/refresh_token_api_response.dart';
import 'package:tomo_place/domains/auth/data/models/signup_api_response.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/network_exception.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/server_exception.dart';
import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../utils/mock_factory/auth_mock_factory.dart';


void main() {
  group('AuthApiDataSource', () {
    late MockAuthApiDataSource mockDataSource;

    setUp(() {
      mockDataSource = AuthMockFactory.createAuthApiDataSource();
    });

    group('authenticate', () {
      test('정상적인 인증 요청이 성공해야 한다', () async {
        // Given
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);
        final authorizationCode = faker.guid.guid();
        final expectedResponse = SignupApiResponse(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
        );

        when(() => mockDataSource.authenticate(
          provider: any(named: 'provider'),
          authorizationCode: any(named: 'authorizationCode'),
        )).thenAnswer((_) => Future.value(expectedResponse));

        // When
        final result = await mockDataSource.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        );

        // Then
        expect(result, equals(expectedResponse));
        verify(() => mockDataSource.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        )).called(1);
      });

      test('네트워크 오류 시 NetworkException을 던져야 한다', () async {
        // Given
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);
        final authorizationCode = faker.guid.guid();
        final networkException = NetworkException.noConnection();

        when(() => mockDataSource.authenticate(
          provider: any(named: 'provider'),
          authorizationCode: any(named: 'authorizationCode'),
        )).thenThrow(networkException);

        // When & Then
        expect(
          () => mockDataSource.authenticate(
            provider: provider,
            authorizationCode: authorizationCode,
          ),
          throwsA(isA<NetworkException>()),
        );
      });

      test('서버 오류 시 ServerException을 던져야 한다', () async {
        // Given
        final provider = faker.randomGenerator.element(['google', 'apple', 'kakao']);
        final authorizationCode = faker.guid.guid();
        final serverException = ServerException.fromStatusCode(
          statusCode: 401,
          message: 'Unauthorized',
        );

        when(() => mockDataSource.authenticate(
          provider: any(named: 'provider'),
          authorizationCode: any(named: 'authorizationCode'),
        )).thenThrow(serverException);

        // When & Then
        expect(
          () => mockDataSource.authenticate(
            provider: provider,
            authorizationCode: authorizationCode,
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('refreshToken', () {
      test('정상적인 토큰 갱신이 성공해야 한다', () async {
        // Given
        final refreshToken = faker.guid.guid();
        final expectedResponse = RefreshTokenApiResponse(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: clock.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: clock.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
        );

        when(() => mockDataSource.refreshToken(any())).thenAnswer((_) => Future.value(expectedResponse));

        // When
        final result = await mockDataSource.refreshToken(refreshToken);

        // Then
        expect(result, equals(expectedResponse));
        verify(() => mockDataSource.refreshToken(refreshToken)).called(1);
      });

      test('만료된 리프레시 토큰으로 실패해야 한다', () async {
        // Given
        final refreshToken = faker.guid.guid();
        final serverException = ServerException.fromStatusCode(
          statusCode: 401,
          message: 'Token expired',
        );

        when(() => mockDataSource.refreshToken(any())).thenThrow(serverException);

        // When & Then
        expect(
          () => mockDataSource.refreshToken(refreshToken),
          throwsA(isA<ServerException>()),
        );
      });

      test('네트워크 오류 시 NetworkException을 던져야 한다', () async {
        // Given
        final refreshToken = faker.guid.guid();
        final networkException = NetworkException.connectionTimeout();

        when(() => mockDataSource.refreshToken(any())).thenThrow(networkException);

        // When & Then
        expect(
          () => mockDataSource.refreshToken(refreshToken),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('logout', () {
      test('정상적인 로그아웃이 성공해야 한다', () async {
        // Given
        when(() => mockDataSource.logout()).thenAnswer((_) => Future.value());

        // When
        await mockDataSource.logout();

        // Then
        verify(() => mockDataSource.logout()).called(1);
      });

      test('네트워크 오류 시 NetworkException을 던져야 한다', () async {
        // Given
        final networkException = NetworkException.noConnection();

        when(() => mockDataSource.logout()).thenThrow(networkException);

        // When & Then
        expect(
          () => mockDataSource.logout(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('서버 오류 시 ServerException을 던져야 한다', () async {
        // Given
        final serverException = ServerException.fromStatusCode(
          statusCode: 500,
          message: 'Internal server error',
        );

        when(() => mockDataSource.logout()).thenThrow(serverException);

        // When & Then
        expect(
          () => mockDataSource.logout(),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });
}
