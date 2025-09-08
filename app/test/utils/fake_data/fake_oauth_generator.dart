import 'package:faker/faker.dart';

/// OAuth 관련 테스트 데이터 생성기
class FakeOAuthGenerator {
  FakeOAuthGenerator._();

  /// 기본 OAuth 데이터 생성
  static Map<String, dynamic> createOAuthData() {
    return {
      'provider': faker.randomGenerator.element(['google', 'apple', 'kakao']),
      'accessToken': faker.guid.guid(),
      'refreshToken': faker.guid.guid(),
      'expiresIn': faker.randomGenerator.integer(3600, min: 1800),
    };
  }

  /// 특정 프로바이더로 OAuth 데이터 생성
  static Map<String, dynamic> createOAuthDataWithProvider(String provider) {
    return {
      'provider': provider,
      'accessToken': faker.guid.guid(),
      'refreshToken': faker.guid.guid(),
      'expiresIn': faker.randomGenerator.integer(3600, min: 1800),
    };
  }

  /// Google OAuth 데이터 생성
  static Map<String, dynamic> createGoogleOAuthData() {
    return {
      'provider': 'google',
      'accessToken': faker.guid.guid(),
      'refreshToken': faker.guid.guid(),
      'expiresIn': 3600,
      'scope': 'openid email profile',
      'idToken': faker.guid.guid(),
    };
  }

  /// Apple OAuth 데이터 생성
  static Map<String, dynamic> createAppleOAuthData() {
    return {
      'provider': 'apple',
      'accessToken': faker.guid.guid(),
      'refreshToken': faker.guid.guid(),
      'expiresIn': 3600,
      'identityToken': faker.guid.guid(),
      'authorizationCode': faker.guid.guid(),
    };
  }

  /// Kakao OAuth 데이터 생성
  static Map<String, dynamic> createKakaoOAuthData() {
    return {
      'provider': 'kakao',
      'accessToken': faker.guid.guid(),
      'refreshToken': faker.guid.guid(),
      'expiresIn': 3600,
      'scope': 'profile_nickname profile_image account_email',
    };
  }

  /// 만료된 OAuth 데이터 생성
  static Map<String, dynamic> createExpiredOAuthData() {
    return {
      'provider': faker.randomGenerator.element(['google', 'apple', 'kakao']),
      'accessToken': faker.guid.guid(),
      'refreshToken': faker.guid.guid(),
      'expiresIn': 0, // 만료됨
    };
  }

  /// 커스텀 만료 시간으로 OAuth 데이터 생성
  static Map<String, dynamic> createOAuthDataWithExpiry(int expiresIn) {
    return {
      'provider': faker.randomGenerator.element(['google', 'apple', 'kakao']),
      'accessToken': faker.guid.guid(),
      'refreshToken': faker.guid.guid(),
      'expiresIn': expiresIn,
    };
  }

  /// OAuth 에러 응답 데이터 생성
  static Map<String, dynamic> createOAuthErrorData({
    String? error,
    String? errorDescription,
  }) {
    return {
      'error': error ?? faker.randomGenerator.element([
        'invalid_request',
        'invalid_client',
        'invalid_grant',
        'unauthorized_client',
        'unsupported_grant_type',
        'invalid_scope',
      ]),
      'error_description': errorDescription ?? faker.lorem.sentence(),
    };
  }
}

