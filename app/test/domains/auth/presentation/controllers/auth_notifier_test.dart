import 'package:app/domains/auth/consts/social_provider.dart';
import 'package:app/domains/auth/core/usecases/logout_usecase.dart';
import 'package:app/domains/auth/core/usecases/refresh_token_usecase.dart';
import 'package:app/domains/auth/core/usecases/signup_with_social_usecase.dart';
import 'package:app/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:app/domains/auth/presentation/models/auth_state.dart';
import 'package:app/shared/error_handling/exceptions/unknown_exception.dart';
import 'package:app/shared/error_handling/models/exception_interface.dart';
import 'package:app/shared/error_handling/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../utils/fake_data_generator.dart';

class _MockSignupWithSocialUseCase extends Mock
    implements SignupWithSocialUseCase {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

class _MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

class _MockErrorEffects extends Mock implements ErrorEffects {}

class _MockErrorInterface extends Mock implements ExceptionInterface {}

void main() {
  group('AuthNotifier', () {
    late _MockSignupWithSocialUseCase mockSignupUseCase;
    late _MockLogoutUseCase mockLogoutUseCase;
    late _MockRefreshTokenUseCase mockRefreshTokenUseCase;
    late _MockErrorEffects mockErrorEffects;
    late AuthNotifier authNotifier;

    setUp(() {
      mockSignupUseCase = _MockSignupWithSocialUseCase();
      mockLogoutUseCase = _MockLogoutUseCase();
      mockRefreshTokenUseCase = _MockRefreshTokenUseCase();
      mockErrorEffects = _MockErrorEffects();
      authNotifier = AuthNotifier(
        mockSignupUseCase,
        mockLogoutUseCase,
        mockRefreshTokenUseCase,
        mockErrorEffects,
      );
    });

    group('초기 상태', () {
      test('초기 상태는 AuthInitial이어야 한다', () {
        // Given & When & Then
        expect(authNotifier.state, isA<AuthInitial>());
      });
    });

    group('signupWithProvider', () {
      test('성공적인 소셜 회원가입 시 AuthSuccess 상태로 변경되어야 한다', () async {
        // Given
        final authToken = FakeDataGenerator.createValidAuthToken();
        when(
          () => mockSignupUseCase.execute(any()),
        ).thenAnswer((_) async => authToken);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        expect(authNotifier.state, isA<AuthSuccess>());
        verify(
          () => mockSignupUseCase.execute(SocialProvider.google),
        ).called(1);
      });

      test('회원가입 중에는 AuthLoading 상태여야 한다', () async {
        // Given
        final authToken = FakeDataGenerator.createValidAuthToken();
        when(
          () => mockSignupUseCase.execute(any()),
        ).thenAnswer((_) async => authToken);

        // When
        final future = authNotifier.signupWithProvider(SocialProvider.google);

        // Then (로딩 중 상태 확인)
        expect(authNotifier.state, isA<AuthLoading>());

        await future;
        expect(authNotifier.state, isA<AuthSuccess>());
      });

      test('토큰이 null인 경우 AuthInitial 상태로 돌아가야 한다', () async {
        // Given
        when(
          () => mockSignupUseCase.execute(any()),
        ).thenAnswer((_) async => null);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        expect(authNotifier.state, isA<AuthInitial>());
        verify(
          () => mockSignupUseCase.execute(SocialProvider.google),
        ).called(1);
      });

      test('회원가입 실패 시 AuthFailure 상태로 변경되어야 한다', () async {
        // Given
        final exception = Exception('Signup failed');
        when(() => mockSignupUseCase.execute(any())).thenThrow(exception);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        expect(authNotifier.state, isA<AuthFailure>());
        final failureState = authNotifier.state as AuthFailure;
        expect(failureState.error.message, contains('Signup failed'));
        verify(() => mockErrorEffects.report(any())).called(1);
      });

      test('다양한 소셜 제공자로 회원가입할 수 있어야 한다', () async {
        // Given
        final authToken = FakeDataGenerator.createValidAuthToken();
        when(
          () => mockSignupUseCase.execute(any()),
        ).thenAnswer((_) async => authToken);

        // When & Then
        await authNotifier.signupWithProvider(SocialProvider.kakao);
        expect(authNotifier.state, isA<AuthSuccess>());
        verify(() => mockSignupUseCase.execute(SocialProvider.kakao)).called(1);

        await authNotifier.signupWithProvider(SocialProvider.apple);
        expect(authNotifier.state, isA<AuthSuccess>());
        verify(() => mockSignupUseCase.execute(SocialProvider.apple)).called(1);
      });
    });

    group('logout', () {
      test('성공적인 로그아웃 시 AuthInitial 상태로 변경되어야 한다', () async {
        // Given
        when(() => mockLogoutUseCase.execute()).thenAnswer((_) async {});

        // When
        await authNotifier.logout();

        // Then
        expect(authNotifier.state, isA<AuthInitial>());
        verify(() => mockLogoutUseCase.execute()).called(1);
      });

      test('로그아웃 중에는 AuthLoading 상태여야 한다', () async {
        // Given
        when(() => mockLogoutUseCase.execute()).thenAnswer((_) async {});

        // When
        final future = authNotifier.logout();

        // Then (로딩 중 상태 확인)
        expect(authNotifier.state, isA<AuthLoading>());

        await future;
        expect(authNotifier.state, isA<AuthInitial>());
      });

      test('로그아웃 실패 시 AuthFailure 상태로 변경되어야 한다', () async {
        // Given
        final exception = Exception('Logout failed');
        when(() => mockLogoutUseCase.execute()).thenThrow(exception);

        // When
        await authNotifier.logout();

        // Then
        expect(authNotifier.state, isA<AuthFailure>());
        final failureState = authNotifier.state as AuthFailure;
        expect(failureState.error.message, contains('Logout failed'));
        verify(() => mockErrorEffects.report(any())).called(1);
      });
    });

    group('에러 처리', () {
      test('ErrorInterface를 상속한 에러는 그대로 전달되어야 한다', () async {
        // Given
        final customError = _MockErrorInterface();
        when(() => customError.message).thenReturn('Custom error');
        when(() => mockSignupUseCase.execute(any())).thenThrow(customError);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        expect(authNotifier.state, isA<AuthFailure>());
        final failureState = authNotifier.state as AuthFailure;
        expect(failureState.error, equals(customError));
        verify(() => mockErrorEffects.report(customError)).called(1);
      });

      test('일반 Exception은 UnknownUiError로 변환되어야 한다', () async {
        // Given
        final exception = Exception('Network error');
        when(() => mockSignupUseCase.execute(any())).thenThrow(exception);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        expect(authNotifier.state, isA<AuthFailure>());
        final failureState = authNotifier.state as AuthFailure;
        expect(failureState.error, isA<UnknownException>());
        expect(failureState.error.message, contains('Network error'));
        verify(() => mockErrorEffects.report(any())).called(1);
      });

      test('String 에러도 UnknownUiError로 변환되어야 한다', () async {
        // Given
        when(() => mockSignupUseCase.execute(any())).thenThrow('String error');

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);

        // Then
        expect(authNotifier.state, isA<AuthFailure>());
        final failureState = authNotifier.state as AuthFailure;
        expect(failureState.error, isA<UnknownException>());
        expect(failureState.error.message, equals('String error'));
        verify(() => mockErrorEffects.report(any())).called(1);
      });
    });

    group('상태 전환', () {
      test('회원가입 성공 후 로그아웃이 가능해야 한다', () async {
        // Given
        final authToken = FakeDataGenerator.createValidAuthToken();
        when(
          () => mockSignupUseCase.execute(any()),
        ).thenAnswer((_) async => authToken);
        when(() => mockLogoutUseCase.execute()).thenAnswer((_) async {});

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);
        expect(authNotifier.state, isA<AuthSuccess>());

        await authNotifier.logout();
        expect(authNotifier.state, isA<AuthInitial>());

        // Then
        verify(
          () => mockSignupUseCase.execute(SocialProvider.google),
        ).called(1);
        verify(() => mockLogoutUseCase.execute()).called(1);
      });

      test('연속된 회원가입 시도가 가능해야 한다', () async {
        // Given
        final authToken = FakeDataGenerator.createValidAuthToken();
        when(
          () => mockSignupUseCase.execute(any()),
        ).thenAnswer((_) async => authToken);

        // When
        await authNotifier.signupWithProvider(SocialProvider.google);
        expect(authNotifier.state, isA<AuthSuccess>());

        await authNotifier.signupWithProvider(SocialProvider.kakao);
        expect(authNotifier.state, isA<AuthSuccess>());

        // Then
        verify(
          () => mockSignupUseCase.execute(SocialProvider.google),
        ).called(1);
        verify(() => mockSignupUseCase.execute(SocialProvider.kakao)).called(1);
      });
    });

    group('의존성 주입', () {
      test('필수 의존성이 올바르게 주입되어야 한다', () {
        // Given & When
        final notifier = AuthNotifier(
          mockSignupUseCase,
          mockLogoutUseCase,
          mockRefreshTokenUseCase,
          mockErrorEffects,
        );

        // Then
        expect(notifier, isA<AuthNotifier>());
        expect(notifier.state, isA<AuthInitial>());
      });
    });
  });
}
