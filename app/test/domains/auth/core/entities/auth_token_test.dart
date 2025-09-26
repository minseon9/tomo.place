import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/core/entities/auth_token.dart';

import '../../../../utils/fake_data/fake_data_generator.dart';
import '../../../../utils/test_time_util.dart';

void main() {
  group('AuthToken', () {
    group('생성자', () {
      test('필수 파라미터로 생성되어야 한다', () {
        // Given
        final accessToken = faker.guid.guid();
        final refreshToken = faker.guid.guid();
        final accessTokenExpiresAt = TestTimeUtils.hoursFromNow(1);
        final refreshTokenExpiresAt = TestTimeUtils.daysFromNow(7);

        // When
        final token = AuthToken(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // Then
        expect(token.accessToken, equals(accessToken));
        expect(token.accessTokenExpiresAt, equals(accessTokenExpiresAt));
        expect(token.refreshToken, equals(refreshToken));
        expect(token.refreshTokenExpiresAt, equals(refreshTokenExpiresAt));
        expect(token.tokenType, equals('Bearer'));
      });

      test('기본값이 올바르게 설정되어야 한다', () {
        // When
        final token = FakeDataGenerator.createValidAuthToken();

        // Then
        expect(token.tokenType, equals('Bearer'));
      });

      test('커스텀 tokenType으로 생성되어야 한다', () {
        // Given
        final customTokenType = faker.randomGenerator.element([
          'Custom',
          'JWT',
          'OAuth',
        ]);

        // When
        final token = AuthToken(
          accessToken: faker.guid.guid(),
          accessTokenExpiresAt: TestTimeUtils.hoursFromNow(1),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: TestTimeUtils.daysFromNow(7),
          tokenType: customTokenType,
        );

        // Then
        expect(token.tokenType, equals(customTokenType));
      });
    });

    group('토큰 만료 검증', () {
      test('만료되지 않은 액세스 토큰은 유효해야 한다', () async {
        await TestTimeUtils.withTokenExpiryScenario(() async {
          // Given
          final token = FakeDataGenerator.createValidAuthToken();

          // When & Then
          expect(token.isAccessTokenExpired, isFalse);
          expect(token.isAccessTokenAboutToExpire, isFalse);
          expect(token.isAccessTokenValid, isTrue);
        });
      });

      test('만료된 액세스 토큰은 무효해야 한다', () {
        // Given
        final token = FakeDataGenerator.createExpiredAuthToken();

        // When & Then
        expect(token.isAccessTokenExpired, isTrue);
        expect(token.isAccessTokenValid, isFalse);
      });

      test('5분 후 만료 예정인 액세스 토큰은 무효해야 한다', () {
        // Given
        final token = FakeDataGenerator.createAboutToExpireAuthToken();

        // When & Then
        expect(token.isAccessTokenAboutToExpire, isTrue);
        expect(token.isAccessTokenValid, isFalse);
      });

      test('만료되지 않은 리프레시 토큰은 유효해야 한다', () {
        // Given
        final token = FakeDataGenerator.createValidAuthToken();

        // When & Then
        expect(token.isRefreshTokenExpired, isFalse);
        expect(token.isRefreshTokenValid, isTrue);
      });

      test('만료된 리프레시 토큰은 무효해야 한다', () {
        // Given
        final token = FakeDataGenerator.createRefreshTokenExpiredAuthToken();

        // When & Then
        expect(token.isRefreshTokenExpired, isTrue);
        expect(token.isRefreshTokenValid, isFalse);
      });
    });

    group('authorizationHeader', () {
      test('올바른 Authorization 헤더를 생성해야 한다', () {
        // Given
        final accessToken = faker.guid.guid();
        final token = AuthToken(
          accessToken: accessToken,
          accessTokenExpiresAt: TestTimeUtils.hoursFromNow(1),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: TestTimeUtils.daysFromNow(7),
        );

        // When
        final header = token.authorizationHeader;

        // Then
        expect(header, equals('Bearer $accessToken'));
      });

      test('커스텀 tokenType으로 올바른 Authorization 헤더를 생성해야 한다', () {
        // Given
        final accessToken = faker.guid.guid();
        final customTokenType = faker.randomGenerator.element([
          'Custom',
          'JWT',
          'OAuth',
        ]);
        final token = AuthToken(
          accessToken: accessToken,
          accessTokenExpiresAt: TestTimeUtils.hoursFromNow(1),
          refreshToken: faker.guid.guid(),
          refreshTokenExpiresAt: TestTimeUtils.daysFromNow(7),
          tokenType: customTokenType,
        );

        // When
        final header = token.authorizationHeader;

        // Then
        expect(header, equals('$customTokenType $accessToken'));
      });
    });

    group('fromJson', () {
      test('정상적인 JSON을 올바르게 파싱해야 한다', () {
        // Given
        final json = FakeDataGenerator.createAuthTokenJson();

        // When
        final token = AuthToken.fromJson(json);

        // Then
        expect(token.accessToken, equals(json['accessToken']));
        expect(token.refreshToken, equals(json['refreshToken']));
        expect(
          token.accessTokenExpiresAt,
          equals(DateTime.parse(json['accessTokenExpiresAt'])),
        );
        expect(
          token.refreshTokenExpiresAt,
          equals(DateTime.parse(json['refreshTokenExpiresAt'])),
        );
        expect(token.tokenType, equals('Bearer'));
      });
    });

    group('객체 속성 비교', () {
      test('동일한 값으로 생성된 객체는 같은 속성을 가져야 한다', () {
        // Given
        final accessToken = faker.guid.guid();
        final refreshToken = faker.guid.guid();
        final accessTokenExpiresAt = TestTimeUtils.hoursFromNow(1);
        final refreshTokenExpiresAt = TestTimeUtils.daysFromNow(7);

        // When
        final token1 = AuthToken(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        final token2 = AuthToken(
          accessToken: accessToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // Then
        expect(token1.accessToken, equals(token2.accessToken));
        expect(token1.refreshToken, equals(token2.refreshToken));
        expect(
          token1.accessTokenExpiresAt,
          equals(token2.accessTokenExpiresAt),
        );
        expect(
          token1.refreshTokenExpiresAt,
          equals(token2.refreshTokenExpiresAt),
        );
        expect(token1.tokenType, equals(token2.tokenType));
      });

      test('다른 값으로 생성된 객체는 다른 속성을 가져야 한다', () {
        // Given
        final accessToken1 = faker.guid.guid();
        final accessToken2 = faker.guid.guid();
        final refreshToken = faker.guid.guid();
        final accessTokenExpiresAt = TestTimeUtils.hoursFromNow(1);
        final refreshTokenExpiresAt = TestTimeUtils.daysFromNow(7);

        // When
        final token1 = AuthToken(
          accessToken: accessToken1,
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        final token2 = AuthToken(
          accessToken: accessToken2, // 다른 토큰
          accessTokenExpiresAt: accessTokenExpiresAt,
          refreshToken: refreshToken,
          refreshTokenExpiresAt: refreshTokenExpiresAt,
        );

        // Then
        expect(token1.accessToken, isNot(equals(token2.accessToken)));
        expect(token1.refreshToken, equals(token2.refreshToken));
        expect(
          token1.accessTokenExpiresAt,
          equals(token2.accessTokenExpiresAt),
        );
        expect(
          token1.refreshTokenExpiresAt,
          equals(token2.refreshTokenExpiresAt),
        );
        expect(token1.tokenType, equals(token2.tokenType));
      });
    });
  });
}
