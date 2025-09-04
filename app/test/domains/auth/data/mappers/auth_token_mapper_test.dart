import 'package:flutter_test/flutter_test.dart';

import 'package:app/domains/auth/data/mappers/auth_token_mapper.dart';
import 'package:app/domains/auth/data/models/refresh_token_api_response.dart';
import 'package:app/domains/auth/data/models/signup_api_response.dart';

void main() {
  group('AuthTokenMapper', () {
    group('fromSignupResponse', () {
      test('SignupApiResponse를 AuthToken으로 올바르게 변환해야 한다', () {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: 'test_access_token',
          accessTokenExpiresAt: 1640995200000, // 2022-01-01 00:00:00 UTC
          refreshToken: 'test_refresh_token',
          refreshTokenExpiresAt: 1643587200000, // 2022-01-31 00:00:00 UTC
        );

        // When
        final authToken = AuthTokenMapper.fromSignupResponse(signupResponse);

        // Then
        expect(authToken.accessToken, equals('test_access_token'));
        expect(authToken.refreshToken, equals('test_refresh_token'));
        expect(authToken.tokenType, equals('Bearer'));
        expect(authToken.accessTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(1640995200000)));
        expect(authToken.refreshTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(1643587200000)));
      });

      test('다양한 타임스탬프로 올바르게 변환해야 한다', () {
        // Given
        final now = DateTime.now();
        final accessExpiry = now.add(const Duration(hours: 1));
        final refreshExpiry = now.add(const Duration(days: 30));

        final signupResponse = SignupApiResponse(
          accessToken: 'dynamic_access_token',
          accessTokenExpiresAt: accessExpiry.millisecondsSinceEpoch,
          refreshToken: 'dynamic_refresh_token',
          refreshTokenExpiresAt: refreshExpiry.millisecondsSinceEpoch,
        );

        // When
        final authToken = AuthTokenMapper.fromSignupResponse(signupResponse);

        // Then
        expect(authToken.accessToken, equals('dynamic_access_token'));
        expect(authToken.refreshToken, equals('dynamic_refresh_token'));
        expect(authToken.accessTokenExpiresAt.millisecondsSinceEpoch, equals(accessExpiry.millisecondsSinceEpoch));
        expect(authToken.refreshTokenExpiresAt.millisecondsSinceEpoch, equals(refreshExpiry.millisecondsSinceEpoch));
      });
    });

    group('fromRefreshTokenResponse', () {
      test('RefreshTokenApiResponse를 AuthToken으로 올바르게 변환해야 한다', () {
        // Given
        final refreshResponse = RefreshTokenApiResponse(
          accessToken: 'new_access_token',
          accessTokenExpiresAt: 1640995200000, // 2022-01-01 00:00:00 UTC
          refreshToken: 'new_refresh_token',
          refreshTokenExpiresAt: 1643587200000, // 2022-01-31 00:00:00 UTC
        );

        // When
        final authToken = AuthTokenMapper.fromRefreshTokenResponse(refreshResponse);

        // Then
        expect(authToken.accessToken, equals('new_access_token'));
        expect(authToken.refreshToken, equals('new_refresh_token'));
        expect(authToken.tokenType, equals('Bearer'));
        expect(authToken.accessTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(1640995200000)));
        expect(authToken.refreshTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(1643587200000)));
      });

      test('토큰 갱신 시 새로운 토큰으로 올바르게 변환해야 한다', () {
        // Given
        final now = DateTime.now();
        final newAccessExpiry = now.add(const Duration(hours: 2));
        final newRefreshExpiry = now.add(const Duration(days: 60));

        final refreshResponse = RefreshTokenApiResponse(
          accessToken: 'refreshed_access_token',
          accessTokenExpiresAt: newAccessExpiry.millisecondsSinceEpoch,
          refreshToken: 'refreshed_refresh_token',
          refreshTokenExpiresAt: newRefreshExpiry.millisecondsSinceEpoch,
        );

        // When
        final authToken = AuthTokenMapper.fromRefreshTokenResponse(refreshResponse);

        // Then
        expect(authToken.accessToken, equals('refreshed_access_token'));
        expect(authToken.refreshToken, equals('refreshed_refresh_token'));
        expect(authToken.accessTokenExpiresAt.millisecondsSinceEpoch, equals(newAccessExpiry.millisecondsSinceEpoch));
        expect(authToken.refreshTokenExpiresAt.millisecondsSinceEpoch, equals(newRefreshExpiry.millisecondsSinceEpoch));
      });
    });

    group('에지 케이스', () {
      test('0 타임스탬프를 올바르게 처리해야 한다', () {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: 'test_token',
          accessTokenExpiresAt: 0,
          refreshToken: 'test_refresh',
          refreshTokenExpiresAt: 0,
        );

        // When
        final authToken = AuthTokenMapper.fromSignupResponse(signupResponse);

        // Then
        expect(authToken.accessTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
        expect(authToken.refreshTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
      });

      test('음수 타임스탬프를 올바르게 처리해야 한다', () {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: 'test_token',
          accessTokenExpiresAt: -1000,
          refreshToken: 'test_refresh',
          refreshTokenExpiresAt: -2000,
        );

        // When
        final authToken = AuthTokenMapper.fromSignupResponse(signupResponse);

        // Then
        expect(authToken.accessTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(-1000)));
        expect(authToken.refreshTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(-2000)));
      });
    });
  });
}
