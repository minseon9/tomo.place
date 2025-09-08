import 'package:tomo_place/domains/auth/data/models/signup_api_response.dart';
import 'package:tomo_place/domains/auth/data/models/refresh_token_api_response.dart';
import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import '../time_test_utils.dart';

/// API 응답 관련 테스트 데이터 생성기
class FakeApiResponseGenerator {
  FakeApiResponseGenerator._();

  // ===== SignupApiResponse 관련 =====

  /// 성공적인 SignupApiResponse 생성
  static SignupApiResponse createSignupResponse() {
    return SignupApiResponse(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: TimeTestUtils.hoursFromNow(1).millisecondsSinceEpoch,
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: TimeTestUtils.daysFromNow(7).millisecondsSinceEpoch,
    );
  }

  /// 커스텀 토큰으로 SignupApiResponse 생성
  static SignupApiResponse createSignupResponseWithTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? accessExpiresAt,
    DateTime? refreshExpiresAt,
  }) {
    return SignupApiResponse(
      accessToken: accessToken,
      accessTokenExpiresAt: (accessExpiresAt ?? TimeTestUtils.hoursFromNow(1)).millisecondsSinceEpoch,
      refreshToken: refreshToken,
      refreshTokenExpiresAt: (refreshExpiresAt ?? TimeTestUtils.daysFromNow(7)).millisecondsSinceEpoch,
    );
  }

  /// 만료된 토큰으로 SignupApiResponse 생성
  static SignupApiResponse createExpiredSignupResponse() {
    return SignupApiResponse(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: TimeTestUtils.hoursAgo(1).millisecondsSinceEpoch,
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: TimeTestUtils.daysAgo(1).millisecondsSinceEpoch,
    );
  }

  /// 곧 만료될 토큰으로 SignupApiResponse 생성
  static SignupApiResponse createAboutToExpireSignupResponse() {
    return SignupApiResponse(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: TimeTestUtils.minutesFromNow(3).millisecondsSinceEpoch,
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: TimeTestUtils.hoursFromNow(1).millisecondsSinceEpoch,
    );
  }

  /// SignupApiResponse JSON 생성
  static Map<String, dynamic> createSignupResponseJson() {
    return {
      'accessToken': faker.guid.guid(),
      'accessTokenExpiresAt': TimeTestUtils.hoursFromNow(1).millisecondsSinceEpoch,
      'refreshToken': faker.guid.guid(),
      'refreshTokenExpiresAt': TimeTestUtils.daysFromNow(7).millisecondsSinceEpoch,
    };
  }

  // ===== RefreshTokenApiResponse 관련 =====

  /// 성공적인 RefreshTokenApiResponse 생성
  static RefreshTokenApiResponse createRefreshTokenResponse() {
    return RefreshTokenApiResponse(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: TimeTestUtils.hoursFromNow(1).millisecondsSinceEpoch,
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: TimeTestUtils.daysFromNow(7).millisecondsSinceEpoch,
    );
  }

  /// 커스텀 토큰으로 RefreshTokenApiResponse 생성
  static RefreshTokenApiResponse createRefreshTokenResponseWithTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? accessExpiresAt,
    DateTime? refreshExpiresAt,
  }) {
    return RefreshTokenApiResponse(
      accessToken: accessToken,
      accessTokenExpiresAt: (accessExpiresAt ?? TimeTestUtils.hoursFromNow(1)).millisecondsSinceEpoch,
      refreshToken: refreshToken,
      refreshTokenExpiresAt: (refreshExpiresAt ?? TimeTestUtils.daysFromNow(7)).millisecondsSinceEpoch,
    );
  }

  /// 만료된 토큰으로 RefreshTokenApiResponse 생성
  static RefreshTokenApiResponse createExpiredRefreshTokenResponse() {
    return RefreshTokenApiResponse(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: TimeTestUtils.hoursAgo(1).millisecondsSinceEpoch,
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: TimeTestUtils.daysAgo(1).millisecondsSinceEpoch,
    );
  }

  /// RefreshTokenApiResponse JSON 생성
  static Map<String, dynamic> createRefreshTokenResponseJson() {
    return {
      'accessToken': faker.guid.guid(),
      'accessTokenExpiresAt': TimeTestUtils.hoursFromNow(1).millisecondsSinceEpoch,
      'refreshToken': faker.guid.guid(),
      'refreshTokenExpiresAt': TimeTestUtils.daysFromNow(7).millisecondsSinceEpoch,
    };
  }

  // ===== 일반 API 응답 관련 =====

  /// 성공적인 API 응답 생성
  static Map<String, dynamic> createSuccessResponse({
    String? message,
    Map<String, dynamic>? data,
  }) {
    return {
      'success': true,
      'message': message ?? 'Success',
      'data': data ?? {},
      'timestamp': clock.now().toIso8601String(),
    };
  }

  /// 실패한 API 응답 생성
  static Map<String, dynamic> createErrorResponse({
    String? message,
    String? errorCode,
    Map<String, dynamic>? data,
  }) {
    return {
      'success': false,
      'message': message ?? faker.lorem.sentence(),
      'error': {
        'code': errorCode ?? faker.randomGenerator.element([
          'AUTH_001',
          'AUTH_002',
          'NET_001',
          'NET_002',
          'VALIDATION_001',
          'VALIDATION_002',
        ]),
        'message': message ?? faker.lorem.sentence(),
      },
      'data': data,
      'timestamp': clock.now().toIso8601String(),
    };
  }

  /// 인증 관련 에러 응답 생성
  static Map<String, dynamic> createAuthErrorResponse({
    String? message,
    String? errorCode,
  }) {
    return createErrorResponse(
      message: message ?? faker.lorem.sentence(),
      errorCode: errorCode ?? faker.randomGenerator.element([
        'AUTH_001',
        'AUTH_002',
        'AUTH_003',
        'TOKEN_EXPIRED',
        'INVALID_TOKEN',
        'UNAUTHORIZED',
      ]),
    );
  }

  /// 네트워크 관련 에러 응답 생성
  static Map<String, dynamic> createNetworkErrorResponse({
    String? message,
    String? errorCode,
  }) {
    return createErrorResponse(
      message: message ?? faker.lorem.sentence(),
      errorCode: errorCode ?? faker.randomGenerator.element([
        'NET_001',
        'NET_002',
        'NET_003',
        'TIMEOUT',
        'CONNECTION_ERROR',
        'SERVER_ERROR',
      ]),
    );
  }

  /// 유효성 검사 에러 응답 생성
  static Map<String, dynamic> createValidationErrorResponse({
    String? message,
    Map<String, List<String>>? fieldErrors,
  }) {
    return {
      'success': false,
      'message': message ?? 'Validation failed',
      'error': {
        'code': 'VALIDATION_001',
        'message': message ?? 'Validation failed',
        'fieldErrors': fieldErrors ?? {
          'email': ['Invalid email format'],
          'password': ['Password must be at least 8 characters'],
        },
      },
      'timestamp': clock.now().toIso8601String(),
    };
  }

  /// 빈 데이터 응답 생성
  static Map<String, dynamic> createEmptyResponse({
    String? message,
  }) {
    return {
      'success': true,
      'message': message ?? 'No data found',
      'data': null,
      'timestamp': clock.now().toIso8601String(),
    };
  }
}
