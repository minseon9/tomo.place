import 'package:flutter_test/flutter_test.dart';

import 'package:app/domains/auth/data/models/signup_api_response.dart';

void main() {
  group('SignupApiResponse', () {
    group('생성자', () {
      test('필수 파라미터로 생성되어야 한다', () {
        // Given & When
        final response = SignupApiResponse(
          accessToken: 'test_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'test_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        // Then
        expect(response.accessToken, equals('test_access_token'));
        expect(response.accessTokenExpiresAt, equals(1640995200000));
        expect(response.refreshToken, equals('test_refresh_token'));
        expect(response.refreshTokenExpiresAt, equals(1643587200000));
      });

      test('const 생성자로 생성되어야 한다', () {
        // Given & When
        const response = SignupApiResponse(
          accessToken: 'const_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'const_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        // Then
        expect(response.accessToken, equals('const_access_token'));
        expect(response.accessTokenExpiresAt, equals(1640995200000));
        expect(response.refreshToken, equals('const_refresh_token'));
        expect(response.refreshTokenExpiresAt, equals(1643587200000));
      });
    });

    group('fromJson', () {
      test('유효한 JSON을 파싱해야 한다', () {
        // Given
        final json = {
          'accessToken': 'json_access_token',
          'accessTokenExpiresAt': 1640995200000,
          'refreshToken': 'json_refresh_token',
          'refreshTokenExpiresAt': 1643587200000,
        };

        // When
        final response = SignupApiResponse.fromJson(json);

        // Then
        expect(response.accessToken, equals('json_access_token'));
        expect(response.accessTokenExpiresAt, equals(1640995200000));
        expect(response.refreshToken, equals('json_refresh_token'));
        expect(response.refreshTokenExpiresAt, equals(1643587200000));
      });

      test('다양한 타입의 JSON 값을 올바르게 파싱해야 한다', () {
        // Given
        final json = {
          'accessToken': 'dynamic_token_123',
          'accessTokenExpiresAt': 1704067200000, // 2024-01-01
          'refreshToken': 'dynamic_refresh_456',
          'refreshTokenExpiresAt': 1706745600000, // 2024-02-01
        };

        // When
        final response = SignupApiResponse.fromJson(json);

        // Then
        expect(response.accessToken, equals('dynamic_token_123'));
        expect(response.accessTokenExpiresAt, equals(1704067200000));
        expect(response.refreshToken, equals('dynamic_refresh_456'));
        expect(response.refreshTokenExpiresAt, equals(1706745600000));
      });

      test('빈 문자열 토큰을 처리해야 한다', () {
        // Given
        final json = {
          'accessToken': '',
          'accessTokenExpiresAt': 0,
          'refreshToken': '',
          'refreshTokenExpiresAt': 0,
        };

        // When
        final response = SignupApiResponse.fromJson(json);

        // Then
        expect(response.accessToken, equals(''));
        expect(response.accessTokenExpiresAt, equals(0));
        expect(response.refreshToken, equals(''));
        expect(response.refreshTokenExpiresAt, equals(0));
      });
    });

    group('불변성', () {
      test('생성 후 값이 변경되지 않아야 한다', () {
        // Given
        final response = SignupApiResponse(
          accessToken: 'immutable_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'immutable_refresh',
          refreshTokenExpiresAt: 1643587200000,
        );

        // When & Then
        expect(response.accessToken, equals('immutable_token'));
        expect(response.accessTokenExpiresAt, equals(1640995200000));
        expect(response.refreshToken, equals('immutable_refresh'));
        expect(response.refreshTokenExpiresAt, equals(1643587200000));
      });
    });

    group('에지 케이스', () {
      test('0 타임스탬프를 처리해야 한다', () {
        // Given & When
        final response = SignupApiResponse(
          accessToken: 'zero_time_token',
          accessTokenExpiresAt: 0,
          refreshToken: 'zero_time_refresh',
          refreshTokenExpiresAt: 0,
        );

        // Then
        expect(response.accessTokenExpiresAt, equals(0));
        expect(response.refreshTokenExpiresAt, equals(0));
      });

      test('음수 타임스탬프를 처리해야 한다', () {
        // Given & When
        final response = SignupApiResponse(
          accessToken: 'negative_time_token',
          accessTokenExpiresAt: -1000,
          refreshToken: 'negative_time_refresh',
          refreshTokenExpiresAt: -2000,
        );

        // Then
        expect(response.accessTokenExpiresAt, equals(-1000));
        expect(response.refreshTokenExpiresAt, equals(-2000));
      });

      test('매우 큰 타임스탬프를 처리해야 한다', () {
        // Given & When
        final response = SignupApiResponse(
          accessToken: 'large_time_token',
          accessTokenExpiresAt: 9999999999999,
          refreshToken: 'large_time_refresh',
          refreshTokenExpiresAt: 9999999999999,
        );

        // Then
        expect(response.accessTokenExpiresAt, equals(9999999999999));
        expect(response.refreshTokenExpiresAt, equals(9999999999999));
      });
    });
  });
}
