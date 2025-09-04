import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/fake_data_generator.dart';
import '../../../../utils/time_test_utils.dart';
import '../../../../utils/test_times.dart';

void main() {
  group('AuthToken', () {
    group('생성자', () {
      test('필수 파라미터로 생성되어야 한다', () {
        final token = AuthToken(
          accessToken: 'test_string',
          accessTokenExpiresAt: TestTimes.tokenValidTime,
          refreshToken: 'test_string',
          refreshTokenExpiresAt: TestTimes.tokenValidTime.add(const Duration(days: 30)),
        );

        expect(token.accessToken, equals('test_string'));
        expect(token.refreshToken, equals('test_string'));
        expect(token.accessTokenExpiresAt, isA<DateTime>());
        expect(token.refreshTokenExpiresAt, isA<DateTime>());
        expect(token.tokenType, equals('Bearer')); // 기본값
      });

      test('기본 tokenType이 Bearer여야 한다', () {
        final token = FakeDataGenerator.createValidAuthToken();

        expect(token.tokenType, equals('Bearer'));
      });
    });

    group('토큰 만료 상태 (시간 고정 테스트)', () {
      test('accessToken이 만료되지 않았을 때 isAccessTokenExpired는 false여야 한다', () async {
        await TimeTestUtils.withFrozenTime(
          TestTimes.fixedTime,
          () async {
            final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
              accessExpiresAt: TestTimes.tokenValidTime,
              refreshExpiresAt: TestTimes.tokenValidTime.add(const Duration(days: 30)),
            );

            expect(token.isAccessTokenExpired, isFalse);
          },
        );
      });

      test('accessToken이 만료되었을 때 isAccessTokenExpired는 true여야 한다', () async {
        await TimeTestUtils.withFrozenTime(
          TestTimes.fixedTime,
          () async {
            final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
              accessExpiresAt: TestTimes.tokenExpiredTime,
              refreshExpiresAt: TestTimes.tokenValidTime.add(const Duration(days: 30)),
            );

            expect(token.isAccessTokenExpired, isTrue);
          },
        );
      });

      test('refreshToken이 만료되지 않았을 때 isRefreshTokenExpired는 false여야 한다', () async {
        await TimeTestUtils.withFrozenTime(
          TestTimes.fixedTime,
          () async {
            final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
              accessExpiresAt: TestTimes.tokenValidTime,
              refreshExpiresAt: TestTimes.tokenValidTime.add(const Duration(days: 30)),
            );

            expect(token.isRefreshTokenExpired, isFalse);
          },
        );
      });

      test('refreshToken이 만료되었을 때 isRefreshTokenExpired는 true여야 한다', () async {
        await TimeTestUtils.withFrozenTime(
          TestTimes.fixedTime,
          () async {
            final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
              accessExpiresAt: TestTimes.tokenValidTime,
              refreshExpiresAt: TestTimes.tokenExpiredTime,
            );

            expect(token.isRefreshTokenExpired, isTrue);
          },
        );
      });
    });

    group('토큰 곧 만료 예정 상태 (시간 고정 테스트)', () {
      test(
        'accessToken이 5분 내에 만료될 때 isAccessTokenAboutToExpire는 true여야 한다',
        () async {
          await TimeTestUtils.withFrozenTime(
            TestTimes.fixedTime,
            () async {
              final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
                accessExpiresAt: TestTimes.tokenAboutToExpireTime,
                refreshExpiresAt: TestTimes.tokenValidTime.add(const Duration(days: 30)),
              );

              expect(token.isAccessTokenAboutToExpire, isTrue);
            },
          );
        },
      );

      test(
        'accessToken이 5분 후에 만료될 때 isAccessTokenAboutToExpire는 false여야 한다',
        () async {
          await TimeTestUtils.withFrozenTime(
            TestTimes.fixedTime,
            () async {
              final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
                accessExpiresAt: TestTimes.tokenValidTime,
                refreshExpiresAt: TestTimes.tokenValidTime.add(const Duration(days: 30)),
              );

              expect(token.isAccessTokenAboutToExpire, isFalse);
            },
          );
        },
      );

      test(
        'refreshToken이 5분 내에 만료될 때 isRefreshTokenAboutToExpire는 true여야 한다',
        () async {
          await TimeTestUtils.withFrozenTime(
            TestTimes.fixedTime,
            () async {
              final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
                accessExpiresAt: TestTimes.tokenValidTime,
                refreshExpiresAt: TestTimes.tokenAboutToExpireTime,
              );

              expect(token.isRefreshTokenAboutToExpire, isTrue);
            },
          );
        },
      );
    });

    group('토큰 유효성 (시간 고정 테스트)', () {
      test(
        'accessToken이 유효할 때 isAccessTokenValid는 true여야 한다',
        () async {
          await TimeTestUtils.withFrozenTime(
            TestTimes.fixedTime,
            () async {
              final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
                accessExpiresAt: TestTimes.tokenValidTime,
                refreshExpiresAt: TestTimes.tokenValidTime.add(const Duration(days: 30)),
              );

              expect(token.isAccessTokenValid, isTrue);
            },
          );
        },
      );

      test('accessToken이 만료되었을 때 isAccessTokenValid는 false여야 한다', () async {
        await TimeTestUtils.withFrozenTime(
          TestTimes.fixedTime,
          () async {
            final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
              accessExpiresAt: TestTimes.tokenExpiredTime,
              refreshExpiresAt: TestTimes.tokenValidTime.add(const Duration(days: 30)),
            );

            expect(token.isAccessTokenValid, isFalse);
          },
        );
      });

      test('refreshToken이 유효할 때 isRefreshTokenValid는 true여야 한다', () async {
        await TimeTestUtils.withFrozenTime(
          TestTimes.fixedTime,
          () async {
            final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
              accessExpiresAt: TestTimes.tokenValidTime,
              refreshExpiresAt: TestTimes.tokenValidTime.add(const Duration(days: 30)),
            );

            expect(token.isRefreshTokenValid, isTrue);
          },
        );
      });

      test('refreshToken이 만료되었을 때 isRefreshTokenValid는 false여야 한다', () async {
        await TimeTestUtils.withFrozenTime(
          TestTimes.fixedTime,
          () async {
            final token = FakeDataGenerator.createAuthTokenWithCustomExpiry(
              accessExpiresAt: TestTimes.tokenValidTime,
              refreshExpiresAt: TestTimes.tokenExpiredTime,
            );

            expect(token.isRefreshTokenValid, isFalse);
          },
        );
      });
    });

    group('authorizationHeader', () {
      test('올바른 형식의 Authorization 헤더를 반환해야 한다', () {
        final token = FakeDataGenerator.createValidAuthToken();

        expect(token.authorizationHeader, startsWith('Bearer '));
        expect(token.authorizationHeader, contains(token.accessToken));
      });
    });

    group('fromJson factory', () {
      test('유효한 JSON을 파싱해야 한다', () {
        final json = FakeDataGenerator.createAuthTokenJson();

        final token = AuthToken.fromJson(json);

        expect(token.accessToken, isNotEmpty);
        expect(token.refreshToken, isNotEmpty);
        expect(token.accessTokenExpiresAt, isA<DateTime>());
        expect(token.refreshTokenExpiresAt, isA<DateTime>());
        expect(token.tokenType, equals('Bearer')); // 기본값
      });

      test('ISO 8601 형식의 날짜를 파싱해야 한다', () {
        final json = {
          'accessToken': 'token',
          'refreshToken': 'refresh',
          'accessTokenExpiresAt': '2024-06-15T10:30:00.000Z',
          'refreshTokenExpiresAt': '2024-07-15T10:30:00.000Z',
        };

        final token = AuthToken.fromJson(json);

        expect(
          token.accessTokenExpiresAt,
          equals(DateTime.parse('2024-06-15T10:30:00.000Z')),
        );
        expect(
          token.refreshTokenExpiresAt,
          equals(DateTime.parse('2024-07-15T10:30:00.000Z')),
        );
      });
    });

    group('불변성', () {
      test('생성 후 값이 변경되지 않아야 한다', () {
        final token = FakeDataGenerator.createValidAuthToken();

        final originalAccessToken = token.accessToken;
        final originalRefreshToken = token.refreshToken;

        expect(token.accessToken, equals(originalAccessToken));
        expect(token.refreshToken, equals(originalRefreshToken));
      });
    });
  });
}