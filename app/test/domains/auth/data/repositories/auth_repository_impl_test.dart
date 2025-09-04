import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/core/exceptions/auth_exception.dart';
import 'package:app/domains/auth/data/datasources/api/auth_api_data_source.dart';
import 'package:app/domains/auth/data/models/refresh_token_api_response.dart';
import 'package:app/domains/auth/data/models/signup_api_response.dart';
import 'package:app/domains/auth/data/repositories/auth_repository_impl.dart';

class _MockAuthApiDataSource extends Mock implements AuthApiDataSource {}

void main() {
  group('AuthRepositoryImpl', () {
    late _MockAuthApiDataSource mockApiDataSource;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockApiDataSource = _MockAuthApiDataSource();
      repository = AuthRepositoryImpl(mockApiDataSource);
    });

    group('authenticate', () {
      test('성공적인 인증 시 AuthToken을 반환해야 한다', () async {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: 'test_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'test_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        when(() => mockApiDataSource.authenticate(
          provider: any(named: 'provider'),
          authorizationCode: any(named: 'authorizationCode'),
        )).thenAnswer((_) async => signupResponse);

        // When
        final result = await repository.authenticate(
          provider: 'google',
          authorizationCode: 'test_auth_code',
        );

        // Then
        expect(result, isA<AuthToken>());
        expect(result.accessToken, equals('test_access_token'));
        expect(result.refreshToken, equals('test_refresh_token'));
        expect(result.tokenType, equals('Bearer'));

        verify(() => mockApiDataSource.authenticate(
          provider: 'google',
          authorizationCode: 'test_auth_code',
        )).called(1);
      });

      test('API 오류 시 AuthException을 던져야 한다', () async {
        // Given
        final apiException = Exception('API Error');
        when(() => mockApiDataSource.authenticate(
          provider: any(named: 'provider'),
          authorizationCode: any(named: 'authorizationCode'),
        )).thenThrow(apiException);

        // When & Then
        expect(
          () => repository.authenticate(
            provider: 'google',
            authorizationCode: 'test_auth_code',
          ),
          throwsA(isA<AuthException>()),
        );

        verify(() => mockApiDataSource.authenticate(
          provider: 'google',
          authorizationCode: 'test_auth_code',
        )).called(1);
      });

      test('다양한 OAuth 제공자로 인증할 수 있어야 한다', () async {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: 'kakao_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'kakao_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        when(() => mockApiDataSource.authenticate(
          provider: any(named: 'provider'),
          authorizationCode: any(named: 'authorizationCode'),
        )).thenAnswer((_) async => signupResponse);

        // When
        final result = await repository.authenticate(
          provider: 'kakao',
          authorizationCode: 'kakao_auth_code',
        );

        // Then
        expect(result.accessToken, equals('kakao_access_token'));
        expect(result.refreshToken, equals('kakao_refresh_token'));

        verify(() => mockApiDataSource.authenticate(
          provider: 'kakao',
          authorizationCode: 'kakao_auth_code',
        )).called(1);
      });
    });

    group('refreshToken', () {
      test('성공적인 토큰 갱신 시 새로운 AuthToken을 반환해야 한다', () async {
        // Given
        final refreshResponse = RefreshTokenApiResponse(
          accessToken: 'new_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'new_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        when(() => mockApiDataSource.refreshToken(any()))
            .thenAnswer((_) async => refreshResponse);

        // When
        final result = await repository.refreshToken('old_refresh_token');

        // Then
        expect(result, isA<AuthToken>());
        expect(result.accessToken, equals('new_access_token'));
        expect(result.refreshToken, equals('new_refresh_token'));
        expect(result.tokenType, equals('Bearer'));

        verify(() => mockApiDataSource.refreshToken('old_refresh_token')).called(1);
      });

      test('토큰 갱신 실패 시 AuthException을 던져야 한다', () async {
        // Given
        final apiException = Exception('Token refresh failed');
        when(() => mockApiDataSource.refreshToken(any()))
            .thenThrow(apiException);

        // When & Then
        expect(
          () => repository.refreshToken('invalid_refresh_token'),
          throwsA(isA<AuthException>()),
        );

        verify(() => mockApiDataSource.refreshToken('invalid_refresh_token')).called(1);
      });

      test('빈 refresh token으로 갱신 시도 시 예외를 던져야 한다', () async {
        // Given
        when(() => mockApiDataSource.refreshToken(any()))
            .thenThrow(Exception('Empty refresh token'));

        // When & Then
        expect(
          () => repository.refreshToken(''),
          throwsA(isA<AuthException>()),
        );

        verify(() => mockApiDataSource.refreshToken('')).called(1);
      });
    });

    group('logout', () {
      test('성공적인 로그아웃을 수행해야 한다', () async {
        // Given
        when(() => mockApiDataSource.logout())
            .thenAnswer((_) async {});

        // When
        await repository.logout();

        // Then
        verify(() => mockApiDataSource.logout()).called(1);
      });

      test('로그아웃 실패 시 예외를 전파해야 한다', () async {
        // Given
        final logoutException = Exception('Logout failed');
        when(() => mockApiDataSource.logout())
            .thenThrow(logoutException);

        // When & Then
        expect(
          () => repository.logout(),
          throwsA(equals(logoutException)),
        );

        verify(() => mockApiDataSource.logout()).called(1);
      });
    });

    group('에러 처리', () {
      test('네트워크 오류를 적절히 처리해야 한다', () async {
        // Given
        final networkException = Exception('Network error');
        when(() => mockApiDataSource.authenticate(
          provider: any(named: 'provider'),
          authorizationCode: any(named: 'authorizationCode'),
        )).thenThrow(networkException);

        // When & Then
        expect(
          () => repository.authenticate(
            provider: 'google',
            authorizationCode: 'test_code',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('서버 오류를 적절히 처리해야 한다', () async {
        // Given
        final serverException = Exception('Server error 500');
        when(() => mockApiDataSource.refreshToken(any()))
            .thenThrow(serverException);

        // When & Then
        expect(
          () => repository.refreshToken('test_refresh_token'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('의존성 주입', () {
      test('AuthApiDataSource가 올바르게 주입되어야 한다', () {
        // Given & When
        final repository = AuthRepositoryImpl(mockApiDataSource);

        // Then
        expect(repository, isA<AuthRepositoryImpl>());
      });

      test('null AuthApiDataSource는 허용되지 않아야 한다', () {
        // Given & When & Then
        expect(
          () => AuthRepositoryImpl(null as dynamic), // ignore: cast_nullable_to_non_nullable
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}
