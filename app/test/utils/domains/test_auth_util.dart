import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/core/entities/authentication_result.dart';
import 'package:tomo_place/domains/auth/core/entities/auth_token.dart';
import 'package:tomo_place/domains/auth/core/repositories/auth_repository.dart';
import 'package:tomo_place/domains/auth/core/repositories/auth_token_repository.dart';
import 'package:tomo_place/domains/auth/core/usecases/logout_usecase.dart';
import 'package:tomo_place/domains/auth/core/usecases/refresh_token_usecase.dart';
import 'package:tomo_place/domains/auth/core/usecases/signup_with_social_usecase.dart';
import 'package:tomo_place/domains/auth/core/usecases/usecase_providers.dart';
import 'package:tomo_place/domains/auth/core/exceptions/auth_exception.dart';
import 'package:tomo_place/domains/auth/core/exceptions/oauth_exception.dart';
import 'package:tomo_place/domains/auth/data/repositories/auth_repository_impl.dart';
import 'package:tomo_place/domains/auth/data/repositories/auth_token_repository_impl.dart';
import 'package:tomo_place/shared/infrastructure/network/auth_client.dart';
import 'package:faker/faker.dart';
import 'package:tomo_place/shared/infrastructure/network/base_client.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthTokenRepository extends Mock implements AuthTokenRepository {}
class MockBaseClient extends Mock implements BaseClient {}
class MockSignupWithSocialUseCase extends Mock implements SignupWithSocialUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

typedef AuthMocks = ({
  MockAuthRepository authRepo,
  MockAuthTokenRepository tokenRepo,
  MockBaseClient baseClient,
  MockSignupWithSocialUseCase signup,
  MockLogoutUseCase logout,
  MockRefreshTokenUseCase refresh,
);

class TestAuthUtil {
  TestAuthUtil._();

  static AuthMocks createMocks() => (
    authRepo: MockAuthRepository(),
    tokenRepo: MockAuthTokenRepository(),
    baseClient: MockBaseClient(),
    signup: MockSignupWithSocialUseCase(),
    logout: MockLogoutUseCase(),
    refresh: MockRefreshTokenUseCase(),
  );

  static AuthToken makeValidToken({
    String? accessToken,
    String? refreshToken,
    DateTime? accessExpiresAt,
    DateTime? refreshExpiresAt,
  }) {
    return AuthToken(
      accessToken: accessToken ?? faker.guid.guid(),
      accessTokenExpiresAt: accessExpiresAt ?? DateTime.now().add(const Duration(hours: 1)),
      refreshToken: refreshToken ?? faker.guid.guid(),
      refreshTokenExpiresAt: refreshExpiresAt ?? DateTime.now().add(const Duration(days: 7)),
    );
  }

  static AuthToken makeExpiredToken() {
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  static AuthToken makeAboutToExpireToken() {
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 3)),
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  static AuthToken makeRefreshTokenExpired() {
    return AuthToken(
      accessToken: faker.guid.guid(),
      accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      refreshToken: faker.guid.guid(),
      refreshTokenExpiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
    );
  }

  static AuthenticationResult makeAuthenticatedResult([AuthToken? token]) {
    return AuthenticationResult.authenticated(token ?? makeValidToken());
  }

  static AuthenticationResult makeUnauthenticatedResult({String? message}) {
    return AuthenticationResult.unauthenticated(message ?? faker.lorem.sentence());
  }

  static AuthenticationResult makeExpiredResult({String? message}) {
    return AuthenticationResult.expired(message ?? faker.lorem.sentence());
  }

  static AuthException makeAuthError({String? message}) {
    return AuthException.authenticationFailed(message: message ?? faker.lorem.sentence());
  }

  static AuthException makeNetworkError() {
    return AuthException.authenticationFailed(
      message: '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.',
    );
  }

  static AuthException makeServerError() {
    return AuthException.authenticationFailed(
      message: '서버에서 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
    );
  }

  static AuthException makeStorageError() {
    return AuthException.authenticationFailed(
      message: '로컬 저장소에 접근할 수 없습니다.',
    );
  }

  static AuthException makeTokenExpiredError() {
    return AuthException.tokenExpired(message: faker.lorem.sentence());
  }

  static OAuthException makeOAuthError({String? provider}) {
    return OAuthException.authenticationFailed(
      provider: provider ?? faker.randomGenerator.element(['google', 'apple', 'kakao']),
      message: faker.lorem.sentence(),
    );
  }

  static void stubUnauthenticated(AuthMocks m) {
    when(() => m.tokenRepo.getCurrentToken()).thenAnswer((_) async => null);
    when(() => m.refresh.execute()).thenAnswer((_) async => makeUnauthenticatedResult());
  }

  static void stubAuthenticated(AuthMocks m, AuthToken token) {
    when(() => m.tokenRepo.getCurrentToken()).thenAnswer((_) async => token);
    when(() => m.refresh.execute()).thenAnswer((_) async => makeAuthenticatedResult(token));
  }

  static void stubSignupSuccess(AuthMocks m, {required SocialProvider provider, required AuthToken token}) {
    when(() => m.signup.execute(provider)).thenAnswer((_) async => token);
    when(() => m.tokenRepo.saveToken(token)).thenAnswer((_) async {});
  }

  static void stubSignupFailure(AuthMocks m, {required SocialProvider provider, required Exception exception}) {
    when(() => m.signup.execute(provider)).thenThrow(exception);
  }

  static void stubRefreshSuccess(AuthMocks m, AuthToken token) {
    when(() => m.refresh.execute()).thenAnswer((_) async => makeAuthenticatedResult(token));
  }

  static void stubRefreshFailure(AuthMocks m, {required Exception exception}) {
    when(() => m.refresh.execute()).thenThrow(exception);
  }

  static void stubLogoutSuccess(AuthMocks m) {
    when(() => m.logout.execute()).thenAnswer((_) async {});
  }

  static void stubLogoutFailure(AuthMocks m, {required Exception exception}) {
    when(() => m.logout.execute()).thenThrow(exception);
  }

  static ({
    Override authRepo,
    Override tokenRepo,
    Override baseClient,
    Override signup,
    Override logout,
    Override refresh,
  }) providerOverrides(AuthMocks m) => (
    authRepo: authRepositoryProvider.overrideWith((_) => m.authRepo),
    tokenRepo: authTokenRepositoryProvider.overrideWith((_) => m.tokenRepo),
    baseClient: authClientProvider.overrideWith((_) => m.baseClient),
    signup: signupWithSocialUseCaseProvider.overrideWith((_) => m.signup),
    logout: logoutUseCaseProvider.overrideWith((_) => m.logout),
    refresh: refreshTokenUseCaseProvider.overrideWith((_) => m.refresh),
  );
}
