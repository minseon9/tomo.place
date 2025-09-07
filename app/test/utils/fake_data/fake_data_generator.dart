import 'package:app/domains/auth/core/entities/auth_token.dart';
import 'package:app/domains/auth/core/entities/authentication_result.dart';
import 'fake_auth_token_generator.dart';
import 'fake_authentication_result_generator.dart';
import 'fake_user_generator.dart';
import 'fake_oauth_generator.dart';
import 'fake_api_response_generator.dart';

/// 통합 테스트 데이터 생성기 (기존 호환성 유지)
/// 
/// 새로운 코드에서는 개별 Generator를 직접 사용하는 것을 권장합니다.
/// 예: FakeAuthTokenGenerator.createValid()
class FakeDataGenerator {
  FakeDataGenerator._();

  // ===== AuthToken 관련 (FakeAuthTokenGenerator로 위임) =====
  
  /// @deprecated FakeAuthTokenGenerator.createValid() 사용을 권장합니다.
  static AuthToken createValidAuthToken() {
    return FakeAuthTokenGenerator.createValid();
  }

  /// @deprecated FakeAuthTokenGenerator.createExpired() 사용을 권장합니다.
  static AuthToken createExpiredAuthToken() {
    return FakeAuthTokenGenerator.createExpired();
  }

  /// @deprecated FakeAuthTokenGenerator.createAboutToExpire() 사용을 권장합니다.
  static AuthToken createAboutToExpireAuthToken() {
    return FakeAuthTokenGenerator.createAboutToExpire();
  }

  /// @deprecated FakeAuthTokenGenerator.createRefreshTokenExpired() 사용을 권장합니다.
  static AuthToken createRefreshTokenExpiredAuthToken() {
    return FakeAuthTokenGenerator.createRefreshTokenExpired();
  }

  /// @deprecated FakeAuthTokenGenerator.createWithCustomExpiry() 사용을 권장합니다.
  static AuthToken createAuthTokenWithCustomExpiry({
    required DateTime accessExpiresAt,
    required DateTime refreshExpiresAt,
  }) {
    return FakeAuthTokenGenerator.createWithCustomExpiry(
      accessExpiresAt: accessExpiresAt,
      refreshExpiresAt: refreshExpiresAt,
    );
  }

  /// @deprecated FakeAuthTokenGenerator.createJson() 사용을 권장합니다.
  static Map<String, dynamic> createAuthTokenJson() {
    return FakeAuthTokenGenerator.createJson();
  }

  // ===== AuthenticationResult 관련 (FakeAuthenticationResultGenerator로 위임) =====

  /// @deprecated FakeAuthenticationResultGenerator.createAuthenticated() 사용을 권장합니다.
  static AuthenticationResult createAuthenticatedResult() {
    return FakeAuthenticationResultGenerator.createAuthenticated();
  }

  /// @deprecated FakeAuthenticationResultGenerator.createUnauthenticated() 사용을 권장합니다.
  static AuthenticationResult createUnauthenticatedResult() {
    return FakeAuthenticationResultGenerator.createUnauthenticated();
  }

  /// @deprecated FakeAuthenticationResultGenerator.createExpired() 사용을 권장합니다.
  static AuthenticationResult createExpiredResult() {
    return FakeAuthenticationResultGenerator.createExpired();
  }

  // ===== 사용자 데이터 관련 (FakeUserGenerator로 위임) =====

  /// @deprecated FakeUserGenerator.createUserData() 사용을 권장합니다.
  static Map<String, dynamic> createUserData() {
    return FakeUserGenerator.createUserData();
  }

  // ===== OAuth 데이터 관련 (FakeOAuthGenerator로 위임) =====

  /// @deprecated FakeOAuthGenerator.createOAuthData() 사용을 권장합니다.
  static Map<String, dynamic> createOAuthData() {
    return FakeOAuthGenerator.createOAuthData();
  }

  // ===== API 응답 관련 (FakeApiResponseGenerator로 위임) =====

  /// @deprecated FakeApiResponseGenerator.createSuccessResponse() 사용을 권장합니다.
  static Map<String, dynamic> createApiResponse({
    bool success = true,
    String? message,
    Map<String, dynamic>? data,
  }) {
    if (success) {
      return FakeApiResponseGenerator.createSuccessResponse(
        message: message,
        data: data,
      );
    } else {
      return FakeApiResponseGenerator.createErrorResponse(
        message: message,
        data: data,
      );
    }
  }

  /// @deprecated FakeApiResponseGenerator.createErrorResponse() 사용을 권장합니다.
  static Map<String, dynamic> createErrorResponse({
    String? errorCode,
    String? message,
  }) {
    return FakeApiResponseGenerator.createErrorResponse(
      errorCode: errorCode,
      message: message,
    );
  }
}

