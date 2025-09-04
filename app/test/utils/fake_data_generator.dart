import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/core/entities/authentication_result.dart';
import 'package:clock/clock.dart';
import 'package:faker/faker.dart';

/// Faker 라이브러리를 사용한 테스트 데이터 생성기
class FakeDataGenerator {
  FakeDataGenerator._();

  // AuthToken 생성 메서드들
  static AuthToken createValidAuthToken() {
    final now = clock.now();
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: now.add(const Duration(hours: 1)),
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: now.add(const Duration(days: 30)),
    );
  }

  static AuthToken createExpiredAuthToken() {
    final now = clock.now();
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: now.subtract(const Duration(hours: 1)),
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: now.subtract(const Duration(days: 1)),
    );
  }

  static AuthToken createAboutToExpireAuthToken() {
    final now = clock.now();
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: now.add(const Duration(minutes: 5)),
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: now.add(const Duration(hours: 1)),
    );
  }

  static AuthToken createAuthTokenWithCustomExpiry({
    required DateTime accessExpiresAt,
    required DateTime refreshExpiresAt,
  }) {
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: accessExpiresAt,
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: refreshExpiresAt,
    );
  }

  // AuthenticationResult 생성 메서드들
  static AuthenticationResult createAuthenticatedResult() {
    return AuthenticationResult.authenticated(createValidAuthToken());
  }

  static AuthenticationResult createUnauthenticatedResult() {
    return AuthenticationResult.unauthenticated();
  }

  static AuthenticationResult createExpiredResult() {
    return AuthenticationResult.expired();
  }

  // JSON 데이터 생성 메서드들
  static Map<String, dynamic> createAuthTokenJson() {
    final now = clock.now();
    return {
      'accessToken': faker.guid.guid(),
      'accessTokenExpiresAt': now
          .add(const Duration(hours: 1))
          .toIso8601String(),
      'refreshToken': faker.guid.guid(),
      'refreshTokenExpiresAt': now
          .add(const Duration(days: 30))
          .toIso8601String(),
      'tokenType': 'Bearer',
    };
  }

  // 사용자 데이터 생성 메서드들
  static Map<String, dynamic> createUserData() {
    return {
      'id': faker.guid.guid(),
      'email': faker.internet.email(),
      'name': faker.person.name(),
      'profileImage': faker.image.loremPicsum(),
    };
  }

  // OAuth 데이터 생성 메서드들
  static Map<String, dynamic> createOAuthData() {
    return {
      'provider': faker.randomGenerator.element(['google', 'apple', 'kakao']),
      'accessToken': faker.guid.guid(),
      'refreshToken': faker.guid.guid(),
      'expiresIn': faker.randomGenerator.integer(3600, min: 1800),
    };
  }

  // 네트워크 응답 데이터 생성
  static Map<String, dynamic> createApiResponse({
    bool success = true,
    String? message,
    Map<String, dynamic>? data,
  }) {
    return {
      'success': success,
      'message': message ?? (success ? 'Success' : faker.lorem.sentence()),
      'data': data ?? {},
      'timestamp': clock.now().toIso8601String(),
    };
  }

  // 에러 응답 데이터 생성
  static Map<String, dynamic> createErrorResponse({
    String? errorCode,
    String? message,
  }) {
    return {
      'success': false,
      'error': {
        'code':
            errorCode ??
            faker.randomGenerator.element(['AUTH_001', 'AUTH_002', 'NET_001']),
        'message': message ?? faker.lorem.sentence(),
      },
      'timestamp': clock.now().toIso8601String(),
    };
  }
}
