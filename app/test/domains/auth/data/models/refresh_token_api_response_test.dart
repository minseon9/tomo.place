import 'package:flutter_test/flutter_test.dart';

import 'package:app/domains/auth/data/models/refresh_token_api_response.dart';

void main() {
  group('RefreshTokenApiResponse', () {
    group('생성자', () {
      test('필수 파라미터로 생성되어야 한다', () {
        // Given & When
        final response = RefreshTokenApiResponse(
          accessToken: 'new_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'new_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        // Then
        expect(response.accessToken, equals('new_access_token'));
        expect(response.accessTokenExpiresAt, equals(1640995200000));
        expect(response.refreshToken, equals('new_refresh_token'));
        expect(response.refreshTokenExpiresAt, equals(1643587200000));
      });

      test('const 생성자로 생성되어야 한다', () {
        // Given & When
        const response = RefreshTokenApiResponse(
          accessToken: 'const_new_access_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'const_new_refresh_token',
          refreshTokenExpiresAt: 1643587200000,
        );

        // Then
        expect(response.accessToken, equals('const_new_access_token'));
        expect(response.accessTokenExpiresAt, equals(1640995200000));
        expect(response.refreshToken, equals('const_new_refresh_token'));
        expect(response.refreshTokenExpiresAt, equals(1643587200000));
      });
    });

    group('fromJson', () {
      test('유효한 JSON을 파싱해야 한다', () {
        // Given
        final json = {
          'accessToken': 'refreshed_access_token',
          'accessTokenExpiresAt': 1640995200000,
          'refreshToken': 'refreshed_refresh_token',
          'refreshTokenExpiresAt': 1643587200000,
        };

        // When
        final response = RefreshTokenApiResponse.fromJson(json);

        // Then
        expect(response.accessToken, equals('refreshed_access_token'));
        expect(response.accessTokenExpiresAt, equals(1640995200000));
        expect(response.refreshToken, equals('refreshed_refresh_token'));
        expect(response.refreshTokenExpiresAt, equals(1643587200000));
      });

      test('토큰 갱신 응답을 올바르게 파싱해야 한다', () {
        // Given
        final now = DateTime.now();
        final newAccessExpiry = now.add(const Duration(hours: 2));
        final newRefreshExpiry = now.add(const Duration(days: 60));

        final json = {
          'accessToken': 'renewed_access_token_${now.millisecondsSinceEpoch}',
          'accessTokenExpiresAt': newAccessExpiry.millisecondsSinceEpoch,
          'refreshToken': 'renewed_refresh_token_${now.millisecondsSinceEpoch}',
          'refreshTokenExpiresAt': newRefreshExpiry.millisecondsSinceEpoch,
        };

        // When
        final response = RefreshTokenApiResponse.fromJson(json);

        // Then
        expect(response.accessToken, equals('renewed_access_token_${now.millisecondsSinceEpoch}'));
        expect(response.accessTokenExpiresAt, equals(newAccessExpiry.millisecondsSinceEpoch));
        expect(response.refreshToken, equals('renewed_refresh_token_${now.millisecondsSinceEpoch}'));
        expect(response.refreshTokenExpiresAt, equals(newRefreshExpiry.millisecondsSinceEpoch));
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
        final response = RefreshTokenApiResponse.fromJson(json);

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
        final response = RefreshTokenApiResponse(
          accessToken: 'immutable_refresh_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'immutable_refresh_refresh',
          refreshTokenExpiresAt: 1643587200000,
        );

        // When & Then
        expect(response.accessToken, equals('immutable_refresh_token'));
        expect(response.accessTokenExpiresAt, equals(1640995200000));
        expect(response.refreshToken, equals('immutable_refresh_refresh'));
        expect(response.refreshTokenExpiresAt, equals(1643587200000));
      });
    });

    group('에지 케이스', () {
      test('0 타임스탬프를 처리해야 한다', () {
        // Given & When
        final response = RefreshTokenApiResponse(
          accessToken: 'zero_time_refresh_token',
          accessTokenExpiresAt: 0,
          refreshToken: 'zero_time_refresh_refresh',
          refreshTokenExpiresAt: 0,
        );

        // Then
        expect(response.accessTokenExpiresAt, equals(0));
        expect(response.refreshTokenExpiresAt, equals(0));
      });

      test('음수 타임스탬프를 처리해야 한다', () {
        // Given & When
        final response = RefreshTokenApiResponse(
          accessToken: 'negative_time_refresh_token',
          accessTokenExpiresAt: -1000,
          refreshToken: 'negative_time_refresh_refresh',
          refreshTokenExpiresAt: -2000,
        );

        // Then
        expect(response.accessTokenExpiresAt, equals(-1000));
        expect(response.refreshTokenExpiresAt, equals(-2000));
      });

      test('매우 큰 타임스탬프를 처리해야 한다', () {
        // Given & When
        final response = RefreshTokenApiResponse(
          accessToken: 'large_time_refresh_token',
          accessTokenExpiresAt: 9999999999999,
          refreshToken: 'large_time_refresh_refresh',
          refreshTokenExpiresAt: 9999999999999,
        );

        // Then
        expect(response.accessTokenExpiresAt, equals(9999999999999));
        expect(response.refreshTokenExpiresAt, equals(9999999999999));
      });
    });

    group('SignupApiResponse와의 일관성', () {
      test('동일한 구조를 가져야 한다', () {
        // Given
        final refreshResponse = RefreshTokenApiResponse(
          accessToken: 'same_structure_token',
          accessTokenExpiresAt: 1640995200000,
          refreshToken: 'same_structure_refresh',
          refreshTokenExpiresAt: 1643587200000,
        );

        // When & Then
        expect(refreshResponse.accessToken, isA<String>());
        expect(refreshResponse.accessTokenExpiresAt, isA<int>());
        expect(refreshResponse.refreshToken, isA<String>());
        expect(refreshResponse.refreshTokenExpiresAt, isA<int>());
      });
    });
  });
}
