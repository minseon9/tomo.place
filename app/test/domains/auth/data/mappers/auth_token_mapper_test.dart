import 'package:tomo_place/domains/auth/data/mappers/auth_token_mapper.dart';
import 'package:tomo_place/domains/auth/data/models/refresh_token_api_response.dart';
import 'package:tomo_place/domains/auth/data/models/signup_api_response.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthTokenMapper', () {
    late String accessToken;
    late String refreshToken;
    late int accessTokenExpiresAt;
    late int refreshTokenExpiresAt;

    setUp(() {
      accessToken = faker.guid.guid();
      refreshToken = faker.guid.guid();
      accessTokenExpiresAt = faker.date.dateTime().millisecondsSinceEpoch;
      refreshTokenExpiresAt = faker.date.dateTime().millisecondsSinceEpoch;
    });

    group('fromSignupResponse', () {
      test('SignupApiResponse를 AuthToken으로 올바르게 변환해야 한다', () {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // When
        final result = AuthTokenMapper.fromSignupResponse(signupResponse);

        // Then
        expect(result.accessToken, equals(accessToken));
        expect(result.refreshToken, equals(refreshToken));
        expect(result.accessTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(accessTokenExpiresAt)));
        expect(result.refreshTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(refreshTokenExpiresAt)));
        expect(result.tokenType, equals('Bearer'));
      });

      test('토큰 타입이 항상 Bearer로 설정되어야 한다', () {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // When
        final result = AuthTokenMapper.fromSignupResponse(signupResponse);

        // Then
        expect(result.tokenType, equals('Bearer'));
      });

      test('밀리초 타임스탬프가 올바르게 DateTime으로 변환되어야 한다', () {
        // Given
        final now = DateTime.now();
        final accessTokenExpiresAt = now.millisecondsSinceEpoch;
        final refreshTokenExpiresAt = now.add(const Duration(hours: 1)).millisecondsSinceEpoch;
        
        final signupResponse = SignupApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // When
        final result = AuthTokenMapper.fromSignupResponse(signupResponse);

        // Then
        expect(result.accessTokenExpiresAt.millisecondsSinceEpoch, equals(accessTokenExpiresAt));
        expect(result.refreshTokenExpiresAt.millisecondsSinceEpoch, equals(refreshTokenExpiresAt));
      });

      test('다양한 타임스탬프 값으로 변환이 올바르게 동작해야 한다', () {
        // Given
        final testCases = [
          {'access': 0, 'refresh': 1000},
          {'access': 1640995200000, 'refresh': 1640998800000}, // 2022-01-01 00:00:00, 01:00:00
          {'access': 1672531200000, 'refresh': 1672534800000}, // 2023-01-01 00:00:00, 01:00:00
        ];

        for (final testCase in testCases) {
          final signupResponse = SignupApiResponse(
            accessToken: accessToken,
            accessTokenExpiresAt: testCase['access']!,
            refreshToken: refreshToken,
            refreshTokenExpiresAt: testCase['refresh']!,
          );

          // When
          final result = AuthTokenMapper.fromSignupResponse(signupResponse);

          // Then
          expect(result.accessTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(testCase['access']!)));
          expect(result.refreshTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(testCase['refresh']!)));
        }
      });
    });

    group('fromRefreshTokenResponse', () {
      test('RefreshTokenApiResponse를 AuthToken으로 올바르게 변환해야 한다', () {
        // Given
        final refreshResponse = RefreshTokenApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // When
        final result = AuthTokenMapper.fromRefreshTokenResponse(refreshResponse);

        // Then
        expect(result.accessToken, equals(accessToken));
        expect(result.refreshToken, equals(refreshToken));
        expect(result.accessTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(accessTokenExpiresAt)));
        expect(result.refreshTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(refreshTokenExpiresAt)));
        expect(result.tokenType, equals('Bearer'));
      });

      test('토큰 타입이 항상 Bearer로 설정되어야 한다', () {
        // Given
        final refreshResponse = RefreshTokenApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // When
        final result = AuthTokenMapper.fromRefreshTokenResponse(refreshResponse);

        // Then
        expect(result.tokenType, equals('Bearer'));
      });

      test('밀리초 타임스탬프가 올바르게 DateTime으로 변환되어야 한다', () {
        // Given
        final now = DateTime.now();
        final accessTokenExpiresAt = now.millisecondsSinceEpoch;
        final refreshTokenExpiresAt = now.add(const Duration(hours: 1)).millisecondsSinceEpoch;
        
        final refreshResponse = RefreshTokenApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // When
        final result = AuthTokenMapper.fromRefreshTokenResponse(refreshResponse);

        // Then
        expect(result.accessTokenExpiresAt.millisecondsSinceEpoch, equals(accessTokenExpiresAt));
        expect(result.refreshTokenExpiresAt.millisecondsSinceEpoch, equals(refreshTokenExpiresAt));
      });

      test('다양한 타임스탬프 값으로 변환이 올바르게 동작해야 한다', () {
        // Given
        final testCases = [
          {'access': 0, 'refresh': 1000},
          {'access': 1640995200000, 'refresh': 1640998800000}, // 2022-01-01 00:00:00, 01:00:00
          {'access': 1672531200000, 'refresh': 1672534800000}, // 2023-01-01 00:00:00, 01:00:00
        ];

        for (final testCase in testCases) {
          final refreshResponse = RefreshTokenApiResponse(
            accessToken: accessToken,
            accessTokenExpiresAt: testCase['access']!,
            refreshToken: refreshToken,
            refreshTokenExpiresAt: testCase['refresh']!,
          );

          // When
          final result = AuthTokenMapper.fromRefreshTokenResponse(refreshResponse);

          // Then
          expect(result.accessTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(testCase['access']!)));
          expect(result.refreshTokenExpiresAt, equals(DateTime.fromMillisecondsSinceEpoch(testCase['refresh']!)));
        }
      });
    });

    group('공통 동작', () {
      test('두 메서드 모두 동일한 변환 로직을 사용해야 한다', () {
        // Given
        final signupResponse = SignupApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        final refreshResponse = RefreshTokenApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // When
        final signupResult = AuthTokenMapper.fromSignupResponse(signupResponse);
        final refreshResult = AuthTokenMapper.fromRefreshTokenResponse(refreshResponse);

        // Then
        expect(signupResult.accessToken, equals(refreshResult.accessToken));
        expect(signupResult.refreshToken, equals(refreshResult.refreshToken));
        expect(signupResult.accessTokenExpiresAt, equals(refreshResult.accessTokenExpiresAt));
        expect(signupResult.refreshTokenExpiresAt, equals(refreshResult.refreshTokenExpiresAt));
        expect(signupResult.tokenType, equals(refreshResult.tokenType));
      });

      test('생성된 AuthToken이 유효한 상태여야 한다', () {
        // Given
        final futureTime = DateTime.now().add(const Duration(hours: 1));
        final signupResponse = SignupApiResponse(
          accessToken: accessToken,
          accessTokenExpiresAt: futureTime.millisecondsSinceEpoch,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: futureTime.add(const Duration(hours: 1)).millisecondsSinceEpoch,
        );

        // When
        final result = AuthTokenMapper.fromSignupResponse(signupResponse);

        // Then
        expect(result.isAccessTokenValid, isTrue);
        expect(result.isRefreshTokenValid, isTrue);
        expect(result.isAccessTokenExpired, isFalse);
        expect(result.isRefreshTokenExpired, isFalse);
      });
    });
  });
}
