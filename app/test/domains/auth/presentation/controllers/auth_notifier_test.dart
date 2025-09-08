import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/core/exceptions/auth_exception.dart';
import 'package:tomo_place/domains/auth/core/usecases/usecase_providers.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';
import 'package:tomo_place/shared/exception_handler/exceptions/unknown_exception.dart';

import '../../../../utils/fake_data/fake_auth_token_generator.dart';
import '../../../../utils/fake_data/fake_authentication_result_generator.dart';
import '../../../../utils/mock_factory/auth_mock_factory.dart';
import '../../../../utils/mock_factory/presentation_mock_factory.dart';

void main() {
  group('AuthNotifier', () {
    late MockSignupWithSocialUseCase mockSignupUseCase;
    late MockLogoutUseCase mockLogoutUseCase;
    late MockRefreshTokenUseCase mockRefreshUseCase;
    late MockExceptionNotifier mockErrorEffects;
    late ProviderContainer container;
    late AuthNotifier authNotifier;

    setUp(() {
      mockSignupUseCase = AuthMockFactory.createSignupUseCase();
      mockLogoutUseCase = AuthMockFactory.createLogoutUseCase();
      mockRefreshUseCase = AuthMockFactory.createRefreshTokenUseCase();
      mockErrorEffects = PresentationMockFactory.createExceptionNotifier();

      // Register fallback values
      registerFallbackValue(SocialProvider.google);
      registerFallbackValue(
        AuthException.authenticationFailed(message: 'Test error'),
      );

      container = ProviderContainer(
        overrides: [
          signupWithSocialUseCaseProvider.overrideWithValue(mockSignupUseCase),
          logoutUseCaseProvider.overrideWithValue(mockLogoutUseCase),
          refreshTokenUseCaseProvider.overrideWithValue(mockRefreshUseCase),
          exceptionNotifierProvider.overrideWith((ref) => mockErrorEffects),
        ],
      );

      authNotifier = container.read(authNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('초기 상태', () {
      test('초기 상태가 AuthInitial이어야 한다', () {
        // When
        final initialState = container.read(authNotifierProvider);

        // Then
        expect(initialState, isA<AuthInitial>());
      });
    });

    group('signupWithProvider', () {
      test('정상적인 소셜 로그인이 성공해야 한다', () async {
        // Given
        final mockToken = FakeAuthTokenGenerator.createValid();
        when(
          () => mockSignupUseCase.execute(any()),
        ).thenAnswer((_) async => mockToken);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthSuccess>());
        expect((currentState as AuthSuccess).isNavigateHome, isTrue);
        verify(
          () => mockSignupUseCase.execute(SocialProvider.google),
        ).called(1);
        verifyNever(() => mockErrorEffects.report(any()));
      });

      test('토큰이 null일 때 AuthInitial 상태로 변경되어야 한다', () async {
        // Given
        when(
          () => mockSignupUseCase.execute(any()),
        ).thenAnswer((_) async => null);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthInitial>());
        verify(
          () => mockSignupUseCase.execute(SocialProvider.google),
        ).called(1);
        verifyNever(() => mockErrorEffects.report(any()));
      });

      test('로그인 실패 시 AuthFailure 상태로 변경되어야 한다', () async {
        // Given
        final authException = AuthException.authenticationFailed(
          message: 'Authentication failed',
        );
        when(() => mockSignupUseCase.execute(any())).thenThrow(authException);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthFailure>());
        expect((currentState as AuthFailure).error, equals(authException));
        verify(
          () => mockSignupUseCase.execute(SocialProvider.google),
        ).called(1);
        verify(() => mockErrorEffects.report(authException)).called(1);
      });

      test('네트워크 오류 시 UnknownException으로 변환되어야 한다', () async {
        // Given
        final networkError = Exception('Network error');
        when(() => mockSignupUseCase.execute(any())).thenThrow(networkError);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthFailure>());
        expect((currentState as AuthFailure).error, isA<UnknownException>());
        verify(
          () => mockSignupUseCase.execute(SocialProvider.google),
        ).called(1);
        verify(() => mockErrorEffects.report(any())).called(1);
      });

      test('로딩 상태가 올바르게 설정되어야 한다', () async {
        // Given
        final mockToken = FakeAuthTokenGenerator.createValid();
        when(() => mockSignupUseCase.execute(any())).thenAnswer((_) async {
          // 로딩 상태 확인
          final loadingState = container.read(authNotifierProvider);
          expect(loadingState, isA<AuthLoading>());
          return mockToken;
        });

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        verify(
          () => mockSignupUseCase.execute(SocialProvider.google),
        ).called(1);
      });
    });

    group('logout', () {
      test('정상적인 로그아웃이 성공해야 한다', () async {
        // Given
        when(() => mockLogoutUseCase.execute()).thenAnswer((_) async {});

        // When
        await authNotifier.logout();

        // Then
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthInitial>());
        verify(() => mockLogoutUseCase.execute()).called(1);
        verifyNever(() => mockErrorEffects.report(any()));
      });

      test('로그아웃 실패 시 AuthFailure 상태로 변경되어야 한다', () async {
        // Given
        final authException = AuthException.authenticationFailed(
          message: 'Logout failed',
        );
        when(() => mockLogoutUseCase.execute()).thenThrow(authException);

        // When
        await authNotifier.logout();

        // Then
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthFailure>());
        expect((currentState as AuthFailure).error, equals(authException));
        verify(() => mockLogoutUseCase.execute()).called(1);
        verify(() => mockErrorEffects.report(authException)).called(1);
      });

      test('로딩 상태가 올바르게 설정되어야 한다', () async {
        // Given
        when(() => mockLogoutUseCase.execute()).thenAnswer((_) async {
          // 로딩 상태 확인
          final loadingState = container.read(authNotifierProvider);
          expect(loadingState, isA<AuthLoading>());
        });

        // When
        await authNotifier.logout();

        // Then
        verify(() => mockLogoutUseCase.execute()).called(1);
      });
    });

    group('refreshToken', () {
      test('인증된 상태에서 토큰 갱신이 성공해야 한다', () async {
        // Given
        final mockResult =
            FakeAuthenticationResultGenerator.createAuthenticated();
        when(
          () => mockRefreshUseCase.execute(),
        ).thenAnswer((_) async => mockResult);

        // When
        final result = await authNotifier.refreshToken(true);

        // Then
        expect(result, equals(mockResult));
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthSuccess>());
        expect((currentState as AuthSuccess).isNavigateHome, isTrue);
        verify(() => mockRefreshUseCase.execute()).called(1);
        verifyNever(() => mockErrorEffects.report(any()));
      });

      test('인증되지 않은 상태에서 AuthInitial로 변경되어야 한다', () async {
        // Given
        final mockResult =
            FakeAuthenticationResultGenerator.createUnauthenticated();
        when(
          () => mockRefreshUseCase.execute(),
        ).thenAnswer((_) async => mockResult);

        // When
        final result = await authNotifier.refreshToken(false);

        // Then
        expect(result, equals(mockResult));
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthInitial>());
        verify(() => mockRefreshUseCase.execute()).called(1);
        verifyNever(() => mockErrorEffects.report(any()));
      });

      test('토큰 갱신 실패 시 AuthFailure 상태로 변경되어야 한다', () async {
        // Given
        final authException = AuthException.tokenExpired(
          message: 'Token refresh failed',
        );
        when(() => mockRefreshUseCase.execute()).thenThrow(authException);

        // When
        final result = await authNotifier.refreshToken(true);

        // Then
        expect(result, isNull);
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthFailure>());
        expect((currentState as AuthFailure).error, equals(authException));
        verify(() => mockRefreshUseCase.execute()).called(1);
        verify(() => mockErrorEffects.report(authException)).called(1);
      });

      test('로딩 상태가 올바르게 설정되어야 한다', () async {
        // Given
        final mockResult =
            FakeAuthenticationResultGenerator.createAuthenticated();
        when(() => mockRefreshUseCase.execute()).thenAnswer((_) async {
          // 로딩 상태 확인
          final loadingState = container.read(authNotifierProvider);
          expect(loadingState, isA<AuthLoading>());
          return mockResult;
        });

        // When
        await authNotifier.refreshToken(true);

        // Then
        verify(() => mockRefreshUseCase.execute()).called(1);
      });
    });

    group('에러 처리 검증', () {
      test('ExceptionInterface는 그대로 처리되어야 한다', () async {
        // Given
        final authException = AuthException.authenticationFailed(
          message: 'Authentication failed',
        );
        when(() => mockSignupUseCase.execute(any())).thenThrow(authException);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthFailure>());
        expect((currentState as AuthFailure).error, equals(authException));
        verify(() => mockErrorEffects.report(authException)).called(1);
      });

      test('일반 Exception은 UnknownException으로 변환되어야 한다', () async {
        // Given
        final generalException = Exception('General error');
        when(
          () => mockSignupUseCase.execute(any()),
        ).thenThrow(generalException);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthFailure>());
        expect((currentState as AuthFailure).error, isA<UnknownException>());
        expect(
          (currentState).error.message,
          equals('Exception: General error'),
        );
        verify(() => mockErrorEffects.report(any())).called(1);
      });

      test('String은 UnknownException으로 변환되어야 한다', () async {
        // Given
        const errorString = 'String error';
        when(() => mockSignupUseCase.execute(any())).thenThrow(errorString);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        final currentState = container.read(authNotifierProvider);
        expect(currentState, isA<AuthFailure>());
        expect((currentState as AuthFailure).error, isA<UnknownException>());
        expect(currentState.error.message, equals('String error'));
        verify(() => mockErrorEffects.report(any())).called(1);
      });
    });

    group('상태 변화 검증', () {
      test('상태 변화가 올바르게 반영되어야 한다', () async {
        // Given
        final mockToken = FakeAuthTokenGenerator.createValid();
        when(
          () => mockSignupUseCase.execute(any()),
        ).thenAnswer((_) async => mockToken);

        // When & Then
        // 초기 상태
        expect(container.read(authNotifierProvider), isA<AuthInitial>());

        // 로딩 상태 (비동기 실행 중)
        final future = authNotifier.signupWithProvider(SocialProvider.google);

        // 성공 상태
        await future;
        expect(container.read(authNotifierProvider), isA<AuthSuccess>());
      });
    });
  });
}
