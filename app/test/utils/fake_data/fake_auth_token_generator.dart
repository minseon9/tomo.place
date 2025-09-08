import 'package:tomo_place/domains/auth/core/entities/auth_token.dart';
import 'package:faker/faker.dart';
import '../time_test_utils.dart';

/// AuthToken 관련 테스트 데이터 생성기
class FakeAuthTokenGenerator {
  FakeAuthTokenGenerator._();

  /// 유효한 AuthToken 생성
  static AuthToken createValid() {
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: TimeTestUtils.hoursFromNow(1),
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: TimeTestUtils.daysFromNow(7),
    );
  }

  /// 만료된 AuthToken 생성
  static AuthToken createExpired() {
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: TimeTestUtils.hoursAgo(1),
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: TimeTestUtils.daysAgo(1),
    );
  }

  /// 곧 만료될 AuthToken 생성 (5분 이내)
  static AuthToken createAboutToExpire() {
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: TimeTestUtils.minutesFromNow(3), // 3분 후 만료
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: TimeTestUtils.hoursFromNow(1),
    );
  }

  /// 리프레시 토큰이 만료된 AuthToken 생성
  static AuthToken createRefreshTokenExpired() {
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: TimeTestUtils.hoursFromNow(1),
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: TimeTestUtils.hoursAgo(1), // 리프레시 토큰 만료
    );
  }

  /// 커스텀 만료 시간으로 AuthToken 생성
  static AuthToken createWithCustomExpiry({
    required DateTime accessExpiresAt,
    required DateTime refreshExpiresAt,
    String? tokenType,
  }) {
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: accessExpiresAt,
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: refreshExpiresAt,
      tokenType: tokenType ?? 'Bearer',
    );
  }

  /// 커스텀 토큰 값으로 AuthToken 생성
  static AuthToken createWithCustomTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? accessExpiresAt,
    DateTime? refreshExpiresAt,
    String? tokenType,
  }) {
    return AuthToken(
      accessToken: accessToken,
      accessTokenExpiresAt: accessExpiresAt ?? TimeTestUtils.hoursFromNow(1),
      refreshToken: refreshToken,
      refreshTokenExpiresAt: refreshExpiresAt ?? TimeTestUtils.daysFromNow(7),
      tokenType: tokenType ?? 'Bearer',
    );
  }

  /// JSON 형태의 AuthToken 데이터 생성
  static Map<String, dynamic> createJson() {
    return {
      'accessToken': faker.guid.guid(),
      'accessTokenExpiresAt': TimeTestUtils.hoursFromNow(1).toIso8601String(),
      'refreshToken': faker.guid.guid(),
      'refreshTokenExpiresAt': TimeTestUtils.daysFromNow(7).toIso8601String(),
      'tokenType': 'Bearer',
    };
  }

  /// 만료된 JSON 형태의 AuthToken 데이터 생성
  static Map<String, dynamic> createExpiredJson() {
    return {
      'accessToken': faker.guid.guid(),
      'accessTokenExpiresAt': TimeTestUtils.hoursAgo(1).toIso8601String(),
      'refreshToken': faker.guid.guid(),
      'refreshTokenExpiresAt': TimeTestUtils.daysAgo(1).toIso8601String(),
      'tokenType': 'Bearer',
    };
  }
}

