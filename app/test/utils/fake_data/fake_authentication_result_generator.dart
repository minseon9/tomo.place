import 'package:tomo_place/domains/auth/core/entities/authentication_result.dart';
import 'package:tomo_place/domains/auth/core/entities/auth_token.dart';
import 'package:faker/faker.dart';
import 'fake_auth_token_generator.dart';

/// AuthenticationResult 관련 테스트 데이터 생성기
class FakeAuthenticationResultGenerator {
  FakeAuthenticationResultGenerator._();

  /// 인증된 상태의 AuthenticationResult 생성
  static AuthenticationResult createAuthenticated([AuthToken? token]) {
    return AuthenticationResult.authenticated(
      token ?? FakeAuthTokenGenerator.createValid(),
    );
  }

  /// 인증되지 않은 상태의 AuthenticationResult 생성
  static AuthenticationResult createUnauthenticated({String? message}) {
    return AuthenticationResult.unauthenticated(
      message ?? faker.lorem.sentence(),
    );
  }

  /// 만료된 상태의 AuthenticationResult 생성
  static AuthenticationResult createExpired({String? message}) {
    return AuthenticationResult.expired(
      message ?? faker.lorem.sentence(),
    );
  }

  /// 커스텀 토큰으로 인증된 상태의 AuthenticationResult 생성
  static AuthenticationResult createAuthenticatedWithToken(
    String accessToken,
    String refreshToken,
  ) {
    return AuthenticationResult.authenticated(
      FakeAuthTokenGenerator.createWithCustomTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );
  }

  /// 만료된 토큰으로 인증된 상태의 AuthenticationResult 생성
  static AuthenticationResult createAuthenticatedWithExpiredToken() {
    return AuthenticationResult.authenticated(
      FakeAuthTokenGenerator.createExpired(),
    );
  }

  /// 곧 만료될 토큰으로 인증된 상태의 AuthenticationResult 생성
  static AuthenticationResult createAuthenticatedWithAboutToExpireToken() {
    return AuthenticationResult.authenticated(
      FakeAuthTokenGenerator.createAboutToExpire(),
    );
  }

  /// 리프레시 토큰이 만료된 상태의 AuthenticationResult 생성
  static AuthenticationResult createAuthenticatedWithRefreshTokenExpired() {
    return AuthenticationResult.authenticated(
      FakeAuthTokenGenerator.createRefreshTokenExpired(),
    );
  }

  /// 기본 메시지로 인증되지 않은 상태의 AuthenticationResult 생성
  static AuthenticationResult createUnauthenticatedWithDefaultMessage() {
    return AuthenticationResult.unauthenticated();
  }

  /// 기본 메시지로 만료된 상태의 AuthenticationResult 생성
  static AuthenticationResult createExpiredWithDefaultMessage() {
    return AuthenticationResult.expired();
  }
}

