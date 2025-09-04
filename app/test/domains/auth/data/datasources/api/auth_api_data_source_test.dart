import 'package:app/domains/auth/data/datasources/api/auth_api_data_source.dart';
import 'package:app/domains/auth/data/models/refresh_token_api_response.dart';
import 'package:app/domains/auth/data/models/signup_api_response.dart';
import 'package:app/shared/infrastructure/network/auth_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthClient extends Mock implements AuthClient {}

void main() {
  group('AuthApiDataSourceImpl', () {
    late _MockAuthClient mockAuthClient;
    late AuthApiDataSourceImpl dataSource;

    setUp(() {
      mockAuthClient = _MockAuthClient();
      dataSource = AuthApiDataSourceImpl(mockAuthClient);
    });

    group('authenticate', () {
      test('성공적인 인증 시 SignupApiResponse를 반환해야 한다', () async {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: 'test_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'test_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        when(
          () => mockAuthClient.post<SignupApiResponse>(any(), any(), any()),
        ).thenAnswer((_) async => signupResponse);

        // When
        final result = await dataSource.authenticate(
          provider: 'google',
          authorizationCode: 'test_auth_code',
        );

        // Then
        expect(result, equals(signupResponse));
        verify(
          () => mockAuthClient.post<SignupApiResponse>('/api/auth/signup', {
            'provider': 'GOOGLE',
            'authorizationCode': 'test_auth_code',
          }, any()),
        ).called(1);
      });

      test('다양한 OAuth 제공자로 인증할 수 있어야 한다', () async {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: 'kakao_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'kakao_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        when(
          () => mockAuthClient.post<SignupApiResponse>(any(), any(), any()),
        ).thenAnswer((_) async => signupResponse);

        // When
        final result = await dataSource.authenticate(
          provider: 'kakao',
          authorizationCode: 'kakao_auth_code',
        );

        // Then
        expect(result, equals(signupResponse));
        verify(
          () => mockAuthClient.post<SignupApiResponse>('/api/auth/signup', {
            'provider': 'KAKAO',
            'authorizationCode': 'kakao_auth_code',
          }, any()),
        ).called(1);
      });

      test('API 오류 시 예외를 전파해야 한다', () async {
        // Given
        final apiException = Exception('API Error');
        when(
          () => mockAuthClient.post<SignupApiResponse>(any(), any(), any()),
        ).thenThrow(apiException);

        // When & Then
        expect(
          () => dataSource.authenticate(
            provider: 'google',
            authorizationCode: 'test_auth_code',
          ),
          throwsA(equals(apiException)),
        );
      });

      test('provider를 대문자로 변환해야 한다', () async {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: 'test_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'test_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        when(
          () => mockAuthClient.post<SignupApiResponse>(any(), any(), any()),
        ).thenAnswer((_) async => signupResponse);

        // When
        await dataSource.authenticate(
          provider: 'apple',
          authorizationCode: 'apple_auth_code',
        );

        // Then
        verify(
          () => mockAuthClient.post<SignupApiResponse>('/api/auth/signup', {
            'provider': 'APPLE',
            'authorizationCode': 'apple_auth_code',
          }, any()),
        ).called(1);
      });
    });

    group('refreshToken', () {
      test('성공적인 토큰 갱신 시 RefreshTokenApiResponse를 반환해야 한다', () async {
        // Given
        final refreshResponse = RefreshTokenApiResponse(
          accessToken: 'new_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'new_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        when(
          () =>
              mockAuthClient.post<RefreshTokenApiResponse>(any(), any(), any()),
        ).thenAnswer((_) async => refreshResponse);

        // When
        final result = await dataSource.refreshToken('old_refresh_token');

        // Then
        expect(result, equals(refreshResponse));
        verify(
          () => mockAuthClient.post<RefreshTokenApiResponse>(
            '/api/auth/refresh',
            {'refreshToken': 'old_refresh_token'},
            any(),
          ),
        ).called(1);
      });

      test('토큰 갱신 실패 시 예외를 전파해야 한다', () async {
        // Given
        final apiException = Exception('Token refresh failed');
        when(
          () =>
              mockAuthClient.post<RefreshTokenApiResponse>(any(), any(), any()),
        ).thenThrow(apiException);

        // When & Then
        expect(
          () => dataSource.refreshToken('invalid_refresh_token'),
          throwsA(equals(apiException)),
        );
      });

      test('빈 refresh token으로 갱신 시도 시 예외를 전파해야 한다', () async {
        // Given
        when(
          () =>
              mockAuthClient.post<RefreshTokenApiResponse>(any(), any(), any()),
        ).thenThrow(Exception('Empty refresh token'));

        // When & Then
        expect(() => dataSource.refreshToken(''), throwsA(isA<Exception>()));
      });
    });

    group('logout', () {
      test('성공적인 로그아웃을 수행해야 한다', () async {
        // Given
        when(
          () => mockAuthClient.post<Map<String, dynamic>>(any(), any(), any()),
        ).thenAnswer((_) async => <String, dynamic>{});

        // When
        await dataSource.logout();

        // Then
        verify(
          () => mockAuthClient.post<Map<String, dynamic>>(
            '/api/auth/logout',
            {},
            any(),
          ),
        ).called(1);
      });

      test('로그아웃 실패 시 예외를 전파해야 한다', () async {
        // Given
        final logoutException = Exception('Logout failed');
        when(
          () => mockAuthClient.post<Map<String, dynamic>>(any(), any(), any()),
        ).thenThrow(logoutException);

        // When & Then
        expect(() => dataSource.logout(), throwsA(equals(logoutException)));
      });
    });

    group('의존성 주입', () {
      test('ApiClient가 올바르게 주입되어야 한다', () {
        // Given & When
        final dataSource = AuthApiDataSourceImpl(mockAuthClient);

        // Then
        expect(dataSource, isA<AuthApiDataSourceImpl>());
      });

      test('null ApiClient는 허용되지 않아야 한다', () {
        // Given & When & Then
        expect(
          () => AuthApiDataSourceImpl(null as dynamic),
          // ignore: cast_nullable_to_non_nullable
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('에러 처리', () {
      test('네트워크 오류를 적절히 처리해야 한다', () async {
        // Given
        final networkException = Exception('Network error');
        when(
          () => mockAuthClient.post<SignupApiResponse>(any(), any(), any()),
        ).thenThrow(networkException);

        // When & Then
        expect(
          () => dataSource.authenticate(
            provider: 'google',
            authorizationCode: 'test_code',
          ),
          throwsA(equals(networkException)),
        );
      });

      test('서버 오류를 적절히 처리해야 한다', () async {
        // Given
        final serverException = Exception('Server error 500');
        when(
          () =>
              mockAuthClient.post<RefreshTokenApiResponse>(any(), any(), any()),
        ).thenThrow(serverException);

        // When & Then
        expect(
          () => dataSource.refreshToken('test_refresh_token'),
          throwsA(equals(serverException)),
        );
      });
    });
  });
}
