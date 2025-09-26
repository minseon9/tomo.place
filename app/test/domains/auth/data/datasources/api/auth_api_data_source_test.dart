import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/auth/data/datasources/api/auth_api_data_source.dart';
import 'package:tomo_place/domains/auth/data/models/refresh_token_api_response.dart';
import 'package:tomo_place/domains/auth/data/models/signup_api_response.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/network_exception.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/server_exception.dart';
import 'package:tomo_place/shared/infrastructure/network/base_client.dart';

class _MockBaseClient extends Mock implements BaseClient {}

void main() {
  group('AuthApiDataSource', () {
    late _MockBaseClient client;
    late AuthApiDataSource dataSource;

    setUp(() {
      client = _MockBaseClient();
      dataSource = AuthApiDataSourceImpl(client);
    });

    group('authenticate', () {
      test('정상적인 인증 요청이 성공해야 한다', () async {
        const provider = 'google';
        const authorizationCode = 'auth-code';
        final expectedResponse = SignupApiResponse(
          accessToken: 'access',
          accessTokenExpiresAt: 1000,
          refreshToken: 'refresh',
          refreshTokenExpiresAt: 2000,
        );

        when(
          () => client.post<SignupApiResponse>(
            any(),
            any<Map<String, dynamic>>(),
            any<SignupApiResponse Function(Map<String, dynamic>)>(),
          ),
        ).thenAnswer((_) async => expectedResponse);

        final result = await dataSource.authenticate(
          provider: provider,
          authorizationCode: authorizationCode,
        );

        expect(result, equals(expectedResponse));
        verify(
          () => client.post<SignupApiResponse>(
            '/api/auth/signup',
            {
              'provider': provider.toUpperCase(),
              'authorizationCode': authorizationCode,
            },
            any<SignupApiResponse Function(Map<String, dynamic>)>(),
          ),
        ).called(1);
      });

      test('네트워크 오류 시 NetworkException을 던져야 한다', () async {
        when(
          () => client.post<SignupApiResponse>(
            any(),
            any<Map<String, dynamic>>(),
            any<SignupApiResponse Function(Map<String, dynamic>)>(),
          ),
        ).thenThrow(NetworkException.noConnection());

        expect(
          () => dataSource.authenticate(provider: 'google', authorizationCode: 'code'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('서버 오류 시 ServerException을 던져야 한다', () async {
        when(
          () => client.post<SignupApiResponse>(
            any(),
            any<Map<String, dynamic>>(),
            any<SignupApiResponse Function(Map<String, dynamic>)>(),
          ),
        ).thenThrow(
          ServerException.fromStatusCode(statusCode: 401, message: 'Unauthorized'),
        );

        expect(
          () => dataSource.authenticate(provider: 'google', authorizationCode: 'code'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('refreshToken', () {
      test('정상적인 토큰 갱신이 성공해야 한다', () async {
        const refreshToken = 'refresh';
        final expectedResponse = RefreshTokenApiResponse(
          accessToken: 'new-access',
          accessTokenExpiresAt: 3000,
          refreshToken: 'new-refresh',
          refreshTokenExpiresAt: 4000,
        );

        when(
          () => client.post<RefreshTokenApiResponse>(
            any(),
            any<Map<String, dynamic>>(),
            any<RefreshTokenApiResponse Function(Map<String, dynamic>)>(),
          ),
        ).thenAnswer((_) async => expectedResponse);

        final result = await dataSource.refreshToken(refreshToken);

        expect(result, equals(expectedResponse));
        verify(
          () => client.post<RefreshTokenApiResponse>(
            '/api/auth/refresh',
            {'refreshToken': refreshToken},
            any<RefreshTokenApiResponse Function(Map<String, dynamic>)>(),
          ),
        ).called(1);
      });

      test('만료된 리프레시 토큰으로 실패해야 한다', () async {
        when(
          () => client.post<RefreshTokenApiResponse>(
            any(),
            any<Map<String, dynamic>>(),
            any<RefreshTokenApiResponse Function(Map<String, dynamic>)>(),
          ),
        ).thenThrow(
          ServerException.fromStatusCode(statusCode: 401, message: 'Token expired'),
        );

        expect(
          () => dataSource.refreshToken('refresh'),
          throwsA(isA<ServerException>()),
        );
      });

      test('네트워크 오류 시 NetworkException을 던져야 한다', () async {
        when(
          () => client.post<RefreshTokenApiResponse>(
            any(),
            any<Map<String, dynamic>>(),
            any<RefreshTokenApiResponse Function(Map<String, dynamic>)>(),
          ),
        ).thenThrow(NetworkException.connectionTimeout());

        expect(
          () => dataSource.refreshToken('refresh'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('logout', () {
      test('정상적인 로그아웃이 성공해야 한다', () async {
        when(
          () => client.post<Map<String, dynamic>>(
            any(),
            any<Map<String, dynamic>>(),
            any<Map<String, dynamic> Function(Map<String, dynamic>)>(),
          ),
        ).thenAnswer((_) async => <String, dynamic>{});

        await dataSource.logout();

        verify(
          () => client.post<Map<String, dynamic>>(
            '/api/auth/logout',
            {},
            any<Map<String, dynamic> Function(Map<String, dynamic>)>(),
          ),
        ).called(1);
      });

      test('네트워크 오류 시 NetworkException을 던져야 한다', () async {
        when(
          () => client.post<Map<String, dynamic>>(
            any(),
            any<Map<String, dynamic>>(),
            any<Map<String, dynamic> Function(Map<String, dynamic>)>(),
          ),
        ).thenThrow(NetworkException.noConnection());

        expect(
          () => dataSource.logout(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('서버 오류 시 ServerException을 던져야 한다', () async {
        when(
          () => client.post<Map<String, dynamic>>(
            any(),
            any<Map<String, dynamic>>(),
            any<Map<String, dynamic> Function(Map<String, dynamic>)>(),
          ),
        ).thenThrow(
          ServerException.fromStatusCode(statusCode: 500, message: 'Internal server error'),
        );

        expect(
          () => dataSource.logout(),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });
}
