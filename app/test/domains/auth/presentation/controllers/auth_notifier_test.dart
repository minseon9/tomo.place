import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';

import '../../../../utils/domains/test_auth_util.dart';
import '../../../../utils/test_exception_util.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SocialProvider.google);
  });

  group('AuthNotifier', () {
    late AuthMocks mocks;
    late ProviderContainer container;
    late MockExceptionNotifier exceptionNotifier;

    setUp(() {
      mocks = TestAuthUtil.createMocks();
      exceptionNotifier = TestExceptionUtil.createMockNotifier();

      final overrides = TestAuthUtil.providerOverrides(
        mocks,
        exceptionNotifier: exceptionNotifier,
      );

      container = ProviderContainer(
        overrides: [
          overrides.authRepo,
          overrides.tokenRepo,
          overrides.baseClient,
          overrides.signup,
          overrides.logout,
          overrides.refresh,
          overrides.exceptionNotifier,
        ],
      );
    });

    tearDown(() {
      container.dispose();
      mocks.resetAll();
    });

    AuthNotifier notifier() => container.read(authNotifierProvider.notifier);

    test('초기 상태는 AuthInitial', () {
      expect(container.read(authNotifierProvider), isA<AuthInitial>());
    });

    group('signupWithProvider', () {
      test('성공 시 AuthSuccess', () async {
        final token = TestAuthUtil.makeValidToken();
        TestAuthUtil.stubSignupSuccess(
          mocks,
          provider: SocialProvider.google,
          token: token,
        );

        await notifier().signupWithProvider(SocialProvider.google);

        final state = container.read(authNotifierProvider);
        expect(state, isA<AuthSuccess>());
        verify(() => mocks.signup.execute(SocialProvider.google)).called(1);
        verifyNever(() => exceptionNotifier.report(any()));
      });

      test('토큰 null 시 AuthInitial', () async {
        when(() => mocks.signup.execute(SocialProvider.google)).thenAnswer((_) async => null);

        await notifier().signupWithProvider(SocialProvider.google);

        expect(container.read(authNotifierProvider), isA<AuthInitial>());
        verifyNever(() => exceptionNotifier.report(any()));
      });

      test('예외 발생 시 AuthFailure', () async {
        final error = TestAuthUtil.makeAuthError();
        TestExceptionUtil.stubReport(exceptionNotifier, result: error);
        when(() => mocks.signup.execute(SocialProvider.google)).thenThrow(error);

        await notifier().signupWithProvider(SocialProvider.google);

        final state = container.read(authNotifierProvider) as AuthFailure;
        expect(state.error, error);
        verify(() => exceptionNotifier.report(error)).called(1);
      });
    });

    group('logout', () {
      test('성공 시 AuthInitial', () async {
        TestAuthUtil.stubLogoutSuccess(mocks);

        await notifier().logout();

        expect(container.read(authNotifierProvider), isA<AuthInitial>());
        verify(() => mocks.logout.execute()).called(1);
        verifyNever(() => exceptionNotifier.report(any()));
      });

      test('실패 시 AuthFailure', () async {
        final error = TestAuthUtil.makeAuthError();
        TestExceptionUtil.stubReport(exceptionNotifier, result: error);
        TestAuthUtil.stubLogoutFailure(mocks, exception: error);

        await notifier().logout();

        final state = container.read(authNotifierProvider) as AuthFailure;
        expect(state.error, error);
        verify(() => exceptionNotifier.report(error)).called(1);
      });
    });

    group('refreshToken', () {
      test('성공 시 AuthSuccess', () async {
        final token = TestAuthUtil.makeValidToken();
        TestAuthUtil.stubRefreshSuccess(mocks, token);

        final result = await notifier().refreshToken(true);

        expect(result, isNotNull);
        expect(container.read(authNotifierProvider), isA<AuthSuccess>());
        verify(() => mocks.refresh.execute()).called(1);
      });

      test('실패 시 AuthFailure', () async {
        final error = TestAuthUtil.makeAuthError();
        TestExceptionUtil.stubReport(exceptionNotifier, result: error);
        TestAuthUtil.stubRefreshFailure(mocks, exception: error);

        final result = await notifier().refreshToken(true);

        expect(result, isNull);
        final state = container.read(authNotifierProvider) as AuthFailure;
        expect(state.error, error);
        verify(() => exceptionNotifier.report(error)).called(1);
      });
    });
  });
}
