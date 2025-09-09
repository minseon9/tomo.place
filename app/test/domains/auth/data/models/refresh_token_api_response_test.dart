import 'package:tomo_place/domains/auth/data/models/refresh_token_api_response.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RefreshTokenApiResponse', () {
    group('생성자', () {
      test('필수 파라미터로 생성되어야 한다', () {
        // Given
        final accessToken = faker.guid.guid();
        final accessTokenExpiresAt = faker.randomGenerator.integer(2147483647); // 2^31 - 1
        final refreshToken = faker.guid.guid();
        final refreshTokenExpiresAt = faker.randomGenerator.integer(2147483647); // 2^31 - 1

        // When
        final response = RefreshTokenApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // Then
        expect(response.accessToken, equals(accessToken));
        expect(response.accessTokenExpiresAt, equals(accessTokenExpiresAt));
        expect(response.refreshToken, equals(refreshToken));
        expect(response.refreshTokenExpiresAt, equals(refreshTokenExpiresAt));
      });

      test('const 생성자로 생성되어야 한다', () {
        // Given
        const response = RefreshTokenApiResponse(
          accessToken: 'test_access_token',
          accessTokenExpiresAt: 1234567890,
          refreshToken: 'test_refresh_token',
          refreshTokenExpiresAt: 9876543210,
        );

        // Then
        expect(response.accessToken, equals('test_access_token'));
        expect(response.accessTokenExpiresAt, equals(1234567890));
        expect(response.refreshToken, equals('test_refresh_token'));
        expect(response.refreshTokenExpiresAt, equals(9876543210));
      });
    });

    group('fromJson', () {
      test('정상적인 JSON을 올바르게 파싱해야 한다', () {
        // Given
        final accessToken = faker.guid.guid();
        final accessTokenExpiresAt = faker.randomGenerator.integer(2147483647); // 2^31 - 1
        final refreshToken = faker.guid.guid();
        final refreshTokenExpiresAt = faker.randomGenerator.integer(2147483647); // 2^31 - 1
        
        final json = {
          'accessToken': accessToken,
          'accessTokenExpiresAt': accessTokenExpiresAt,
          'refreshToken': refreshToken,
          'refreshTokenExpiresAt': refreshTokenExpiresAt,
        };

        // When
        final response = RefreshTokenApiResponse.fromJson(json);

        // Then
        expect(response.accessToken, equals(accessToken));
        expect(response.accessTokenExpiresAt, equals(accessTokenExpiresAt));
        expect(response.refreshToken, equals(refreshToken));
        expect(response.refreshTokenExpiresAt, equals(refreshTokenExpiresAt));
      });

      test('null 값이 포함된 JSON은 타입 캐스팅 오류를 발생시켜야 한다', () {
        // Given
        final json = {
          'accessToken': null,
          'accessTokenExpiresAt': 1234567890,
          'refreshToken': 'test_refresh_token',
          'refreshTokenExpiresAt': 9876543210,
        };

        // When & Then
        expect(
          () => RefreshTokenApiResponse.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('잘못된 타입의 JSON은 타입 캐스팅 오류를 발생시켜야 한다', () {
        // Given
        final json = {
          'accessToken': 'test_access_token',
          'accessTokenExpiresAt': 'invalid_timestamp', // String instead of int
          'refreshToken': 'test_refresh_token',
          'refreshTokenExpiresAt': 9876543210,
        };

        // When & Then
        expect(
          () => RefreshTokenApiResponse.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('누락된 필드가 있는 JSON은 타입 캐스팅 오류를 발생시켜야 한다', () {
        // Given
        final json = {
          'accessToken': 'test_access_token',
          'accessTokenExpiresAt': 1234567890,
          // refreshToken 누락
          'refreshTokenExpiresAt': 9876543210,
        };

        // When & Then
        expect(
          () => RefreshTokenApiResponse.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('객체 속성 비교', () {
      test('동일한 값으로 생성된 객체는 같은 속성을 가져야 한다', () {
        // Given
        const accessToken = 'test_access_token';
        const accessTokenExpiresAt = 1234567890;
        const refreshToken = 'test_refresh_token';
        const refreshTokenExpiresAt = 9876543210;

        // When
        const response1 = RefreshTokenApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        const response2 = RefreshTokenApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // Then
        expect(response1.accessToken, equals(response2.accessToken));
        expect(response1.accessTokenExpiresAt, equals(response2.accessTokenExpiresAt));
        expect(response1.refreshToken, equals(response2.refreshToken));
        expect(response1.refreshTokenExpiresAt, equals(response2.refreshTokenExpiresAt));
      });

      test('다른 값으로 생성된 객체는 다른 속성을 가져야 한다', () {
        // Given
        const response1 = RefreshTokenApiResponse(
          accessToken: 'token1',
          accessTokenExpiresAt: 1234567890,
          refreshToken: 'refresh1',
          refreshTokenExpiresAt: 9876543210,
        );

        const response2 = RefreshTokenApiResponse(
          accessToken: 'token2',
          accessTokenExpiresAt: 1234567890,
          refreshToken: 'refresh1',
          refreshTokenExpiresAt: 9876543210,
        );

        // Then
        expect(response1.accessToken, isNot(equals(response2.accessToken)));
        expect(response1.accessTokenExpiresAt, equals(response2.accessTokenExpiresAt));
        expect(response1.refreshToken, equals(response2.refreshToken));
        expect(response1.refreshTokenExpiresAt, equals(response2.refreshTokenExpiresAt));
      });
    });
  });
}
