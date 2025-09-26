import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faker/faker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/core/entities/authentication_result.dart';
import 'package:tomo_place/domains/auth/core/entities/auth_token.dart';
import 'package:tomo_place/domains/auth/core/exceptions/auth_exception.dart';
import 'package:tomo_place/domains/auth/core/exceptions/oauth_exception.dart';
import 'package:tomo_place/domains/auth/core/repositories/auth_repository.dart';
import 'package:tomo_place/domains/auth/core/repositories/auth_token_repository.dart';
import 'package:tomo_place/domains/auth/core/usecases/logout_usecase.dart';
import 'package:tomo_place/domains/auth/core/usecases/refresh_token_usecase.dart';
import 'package:tomo_place/domains/auth/core/usecases/signup_with_social_usecase.dart';
import 'package:tomo_place/domains/auth/core/usecases/usecase_providers.dart';
import 'package:tomo_place/domains/auth/data/repositories/auth_repository_impl.dart';
import 'package:tomo_place/domains/auth/data/repositories/auth_token_repository_impl.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';
import '../test_exception_util.dart';
import 'package:tomo_place/shared/infrastructure/network/auth_client.dart';
import 'package:tomo_place/shared/infrastructure/network/base_client.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthTokenRepository extends Mock implements AuthTokenRepository {}
class MockBaseClient extends Mock implements BaseClient {}
class MockSignupWithSocialUseCase extends Mock implements SignupWithSocialUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}
class MockAuthNotifier extends Mock implements AuthNotifier {}

class AuthMocks {
  MockAuthRepository? _authRepo;
  MockAuthTokenRepository? _tokenRepo;
  MockBaseClient? _baseClient;
  MockSignupWithSocialUseCase? _signup;
  MockLogoutUseCase? _logout;
  MockRefreshTokenUseCase? _refresh;
  MockAuthNotifier? _authNotifier;

  MockAuthRepository get authRepo => _authRepo ??= MockAuthRepository();
  MockAuthTokenRepository get tokenRepo => _tokenRepo ??= MockAuthTokenRepository();
  MockBaseClient get baseClient => _baseClient ??= MockBaseClient();
  MockSignupWithSocialUseCase get signup => _signup ??= MockSignupWithSocialUseCase();
  MockLogoutUseCase get logout => _logout ??= MockLogoutUseCase();
  MockRefreshTokenUseCase get refresh => _refresh ??= MockRefreshTokenUseCase();
  MockAuthNotifier get authNotifier => _authNotifier ??= MockAuthNotifier();

  void resetAll() {
    if (_authRepo != null) reset(_authRepo);
    if (_tokenRepo != null) reset(_tokenRepo);
    if (_baseClient != null) reset(_baseClient);
    if (_signup != null) reset(_signup);
    if (_logout != null) reset(_logout);
    if (_refresh != null) reset(_refresh);
    if (_authNotifier != null) reset(_authNotifier);
  }
}

class TestAuthUtil {
  TestAuthUtil._();

  static AuthMocks createMocks() => AuthMocks();

  static void registerFallbackValues() {
    registerFallbackValue(true);
    registerFallbackValue(const AuthInitial());
    registerFallbackValue(const AuthSuccess(false));
    registerFallbackValue(AuthFailure(error: makeAuthError(message: 'fallback')));
  }

  static void stubAuthNotifierLifecycle(AuthMocks m) {
    when(
      () => m.authNotifier.addListener(
        any(),
        fireImmediately: any(named: 'fireImmediately'),
      ),
    ).thenReturn(() {});
  }

  static void stubAuthState(AuthMocks m, AuthState state) {
    when(() => m.authNotifier.state).thenReturn(state);
  }

  static void stubAuthRefreshInitial(AuthMocks m) {
    when(() => m.authNotifier.refreshToken(any())).thenAnswer((_) async => null);
    stubAuthState(m, const AuthInitial());
  }

  static void stubAuthRefreshSuccess(
    AuthMocks m, {
    AuthenticationResult? result,
    bool isLogin = true,
  }) {
    final authenticationResult = result ?? makeAuthenticatedResult();
    when(() => m.authNotifier.refreshToken(any())).thenAnswer((_) async => authenticationResult);
    stubAuthState(m, AuthSuccess(isLogin));
  }

  static void stubAuthRefreshFailure(
    AuthMocks m, {
    required Exception exception,
    AuthState? nextState,
  }) {
    when(() => m.authNotifier.refreshToken(any())).thenThrow(exception);
    if (nextState != null) {
      stubAuthState(m, nextState);
    }
  }

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
    Override exceptionNotifier,
  }) providerOverrides(
    AuthMocks m, {
    MockExceptionNotifier? exceptionNotifier,
  }) => (
        authRepo: authRepositoryProvider.overrideWith((_) => m.authRepo),
        tokenRepo: authTokenRepositoryProvider.overrideWith((_) => m.tokenRepo),
        baseClient: authClientProvider.overrideWith((_) => m.baseClient),
        signup: signupWithSocialUseCaseProvider.overrideWith((_) => m.signup),
        logout: logoutUseCaseProvider.overrideWith((_) => m.logout),
        refresh: refreshTokenUseCaseProvider.overrideWith((_) => m.refresh),
        exceptionNotifier: TestExceptionUtil.overrideProvider(
          exceptionNotifier ?? TestExceptionUtil.createMockNotifier(),
        ),
      );

  static Override authNotifierOverride(AuthMocks m) =>
      authNotifierProvider.overrideWith((_) => m.authNotifier);
}
