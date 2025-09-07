import 'package:app/app/app.dart';
import 'package:app/domains/auth/core/entities/authentication_result.dart';
import 'package:app/domains/auth/core/usecases/refresh_token_usecase.dart';
import 'package:app/domains/auth/core/usecases/usecase_providers.dart';
import 'package:app/domains/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/domains/auth/data/repositories/auth_token_repository_impl.dart';
import 'package:app/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:app/domains/auth/presentation/models/auth_state.dart';
import 'package:app/domains/auth/presentation/pages/signup_page.dart';
import 'package:app/shared/application/navigation/navigation_key.dart';
import 'package:app/shared/exception_handler/exception_notifier.dart';
import 'package:app/shared/infrastructure/network/auth_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../utils/fake_data/fake_auth_token_generator.dart';
import '../utils/fake_data/fake_authentication_result_generator.dart';
import '../utils/fake_data/fake_exception_generator.dart';
import '../utils/mock_factory/auth_mock_factory.dart';
import '../utils/mock_factory/shared_mock_factory.dart';

// Mock 클래스들
class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

void main() {
  group('App Flow Integration Test', () {
    late MockAuthRepository mockAuthRepository;
    late MockAuthTokenRepository mockAuthTokenRepository;
    late MockBaseClient mockBaseClient;
    late MockRefreshTokenUseCase mockRefreshTokenUseCase;

    setUp(() {
      // Mock 객체들 생성
      mockAuthRepository = AuthMockFactory.createAuthRepository();
      mockAuthTokenRepository = AuthMockFactory.createAuthTokenRepository();
      mockBaseClient = SharedMockFactory.createBaseClient();
      mockRefreshTokenUseCase = MockRefreshTokenUseCase();

      // Register fallback values
      registerFallbackValue(true);
      registerFallbackValue(false);
      registerFallbackValue(0);
      registerFallbackValue('');
      registerFallbackValue(<String, dynamic>{});
      registerFallbackValue(<String>[]);
      registerFallbackValue(AuthInitial());
      registerFallbackValue(AuthLoading());
      registerFallbackValue(AuthSuccess(true));
      registerFallbackValue(AuthFailure(error: FakeExceptionGenerator.createAuthenticationFailed()));
      registerFallbackValue(FakeExceptionGenerator.createAuthenticationFailed());
      registerFallbackValue(GlobalKey<NavigatorState>());
      registerFallbackValue(AuthenticationResult.authenticated(FakeAuthTokenGenerator.createValid()));
      registerFallbackValue(AuthenticationResult.unauthenticated());
    });

    tearDown(() {
      // 테스트 간 상태 격리를 위한 정리
      reset(mockAuthRepository);
      reset(mockAuthTokenRepository);
      reset(mockBaseClient);
      reset(mockRefreshTokenUseCase);
    });

    // Helper 함수들
    Widget createTestApp({List<Override> overrides = const []}) {
      return ProviderScope(
        overrides: [
          // Mock Provider들 추가
          authRepositoryProvider.overrideWith((ref) => mockAuthRepository),
          authTokenRepositoryProvider.overrideWith((ref) => mockAuthTokenRepository),
          authClientProvider.overrideWith((ref) => mockBaseClient),
          refreshTokenUseCaseProvider.overrideWith((ref) => mockRefreshTokenUseCase),
          ...overrides,
        ],
        child: const TomoPlaceApp(),
      );
    }

    group('앱 시작 플로우', () {
      testWidgets('유효한 토큰이 있을 때 홈 화면으로 네비게이션되어야 한다', (WidgetTester tester) async {
        // Given - 유효한 토큰이 있는 상황
        final validToken = FakeAuthTokenGenerator.createValid();
        final authResult = FakeAuthenticationResultGenerator.createAuthenticated(validToken);

        when(() => mockRefreshTokenUseCase.execute())
            .thenAnswer((_) async => authResult);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        
        // 로딩 상태 확인
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        await tester.pumpAndSettle();

        // Then - 더 구체적인 검증
        expect(find.byType(MaterialApp), findsOneWidget);
        
        // Auth 상태 검증
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthSuccess>());
        expect((authState as AuthSuccess).isNavigateHome, isTrue);
        
        // UseCase 호출 확인
        verify(() => mockRefreshTokenUseCase.execute()).called(1);
        
        // 홈 화면으로 네비게이션되었는지 확인
        expect(find.text('홈 화면 (추후 구현)'), findsOneWidget);
      });

      testWidgets('토큰이 없을 때 로그인 화면으로 네비게이션되어야 한다', (WidgetTester tester) async {
        // Given - 토큰이 없는 상황
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => null);
        when(() => mockRefreshTokenUseCase.execute())
            .thenAnswer((_) async => FakeAuthenticationResultGenerator.createUnauthenticated());

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        
        // 로딩 상태 확인
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        await tester.pumpAndSettle();

        // Then - 에러 상태 및 UI 검증
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthInitial>());
        
        // 로그인 화면으로 네비게이션되었는지 확인
        expect(find.byType(SignupPage), findsOneWidget);
      });

      testWidgets('네트워크 오류 시 에러 처리와 스낵바가 표시되어야 한다', (WidgetTester tester) async {
        // Given - 네트워크 오류 상황
        final exception = FakeExceptionGenerator.createNetworkError();
        when(() => mockRefreshTokenUseCase.execute())
            .thenThrow(exception);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 에러 상태 및 UI 검증
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
        
        // 에러 스낵바가 표시되는지 확인
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(exception.userMessage), findsOneWidget);
      });
    });

    group('네비게이션 플로우', () {
      testWidgets('인증 상태에 따른 자동 네비게이션이 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given - 인증되지 않은 상태
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => null);
        when(() => mockRefreshTokenUseCase.execute())
            .thenAnswer((_) async => FakeAuthenticationResultGenerator.createUnauthenticated());

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 실제 네비게이션 테스트
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        expect(navigator, isNotNull);
        
        // 현재 루트 확인 - 로그인 화면이 표시되어야 함
        expect(find.byType(SignupPage), findsOneWidget);
        
        // 네비게이션이 올바르게 설정되었는지 확인
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.navigatorKey, isA<GlobalKey<NavigatorState>>());
        expect(materialApp.onGenerateRoute, isNotNull);
      });

      testWidgets('인증 성공 시 홈 화면으로 자동 네비게이션되어야 한다', (WidgetTester tester) async {
        // Given - 인증 성공 상황
        final validToken = FakeAuthTokenGenerator.createValid();
        
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => validToken);
        when(() => mockRefreshTokenUseCase.execute())
            .thenAnswer((_) async => FakeAuthenticationResultGenerator.createAuthenticated(validToken));

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 홈 화면으로 네비게이션되었는지 확인
        expect(find.text('홈 화면 (추후 구현)'), findsOneWidget);
        expect(find.byType(SignupPage), findsNothing);
      });

      testWidgets('네비게이션 스택이 올바르게 관리되어야 한다', (WidgetTester tester) async {
        // Given - 인증되지 않은 상태
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => null);
        when(() => mockRefreshTokenUseCase.execute())
            .thenAnswer((_) async => FakeAuthenticationResultGenerator.createUnauthenticated());

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 네비게이션 스택 확인
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        expect(navigator.canPop(), isFalse); // 루트 화면이므로 뒤로가기 불가능
      });
    });

    group('상태 관리 플로우', () {
      testWidgets('인증 상태 변화가 올바르게 전파되어야 한다', (WidgetTester tester) async {
        // Given - 앱 시작
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => null);
        when(() => mockRefreshTokenUseCase.execute())
            .thenAnswer((_) async => FakeAuthenticationResultGenerator.createUnauthenticated());

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - AuthState 변화 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        
        expect(authState, isA<AuthInitial>());
      });

      testWidgets('Provider 상태 동기화가 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given - 앱 시작
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => null);
        when(() => mockRefreshTokenUseCase.execute())
            .thenAnswer((_) async => FakeAuthenticationResultGenerator.createUnauthenticated());

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - Provider들이 올바르게 초기화되었는지 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        
        expect(container.read(authNotifierProvider.notifier), isA<AuthNotifier>());
        expect(container.read(exceptionNotifierProvider.notifier), isA<ExceptionNotifier>());
        expect(container.read(navigatorKeyProvider), isA<GlobalKey<NavigatorState>>());
      });

      testWidgets('로딩 상태에서 성공 상태로의 전환이 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given - 인증 성공 상황
        final validToken = FakeAuthTokenGenerator.createValid();
        
        when(() => mockAuthTokenRepository.getCurrentToken())
            .thenAnswer((_) async => validToken);
        when(() => mockRefreshTokenUseCase.execute())
            .thenAnswer((_) async => FakeAuthenticationResultGenerator.createAuthenticated(validToken));

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        
        // 로딩 상태 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        await tester.pumpAndSettle();
        
        // Then - 최종 상태 확인
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthSuccess>());
        expect((authState as AuthSuccess).isNavigateHome, isTrue);
      });

      testWidgets('로딩 상태에서 실패 상태로의 전환이 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given - 인증 실패 상황
        final exception = FakeExceptionGenerator.createAuthenticationFailed();
        when(() => mockRefreshTokenUseCase.execute())
            .thenThrow(exception);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        
        // 로딩 상태 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        await tester.pumpAndSettle();
        
        // Then - 최종 상태 확인
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
        expect((authState as AuthFailure).error, equals(exception));
      });
    });

    group('에러 처리 플로우', () {
      testWidgets('전역 에러 처리가 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given - 에러가 발생하는 상황
        final exception = FakeExceptionGenerator.createStorageError();
        when(() => mockRefreshTokenUseCase.execute())
            .thenThrow(exception);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 에러가 ExceptionNotifier를 통해 처리되는지 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
        
        // 에러 스낵바가 표시되는지 확인
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(exception.userMessage), findsOneWidget);
      });

      testWidgets('다양한 에러 타입이 올바르게 처리되어야 한다', (WidgetTester tester) async {
        // Given - 네트워크 에러 상황
        final networkException = FakeExceptionGenerator.createNetworkError();
        when(() => mockRefreshTokenUseCase.execute())
            .thenThrow(networkException);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 네트워크 에러가 올바르게 처리되는지 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
        
        // 에러 스낵바가 표시되는지 확인
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(networkException.userMessage), findsOneWidget);
      });
    });

    group('인증 상태 변화 플로우', () {
      testWidgets('토큰 만료 시 자동 갱신이 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given - 만료된 토큰이 있는 상황
        final newToken = FakeAuthTokenGenerator.createValid();
        final authResult = FakeAuthenticationResultGenerator.createAuthenticated(newToken);
        
        when(() => mockRefreshTokenUseCase.execute())
            .thenAnswer((_) async => authResult);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 토큰 갱신이 성공적으로 이루어졌는지 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthSuccess>());
        
        // UseCase 호출 확인
        verify(() => mockRefreshTokenUseCase.execute()).called(1);
      });

      testWidgets('토큰 갱신 실패 시 로그인 화면으로 이동해야 한다', (WidgetTester tester) async {
        // Given - 토큰 갱신 실패 상황
        final exception = FakeExceptionGenerator.createTokenExpired();
        
        when(() => mockRefreshTokenUseCase.execute())
            .thenThrow(exception);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 로그인 화면으로 이동했는지 확인
        expect(find.byType(SignupPage), findsOneWidget);
        
        // 에러 상태 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
      });

      testWidgets('네트워크 오류 후 재시도 플로우가 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given - 네트워크 오류 상황
        final networkException = FakeExceptionGenerator.createNetworkError();
        when(() => mockRefreshTokenUseCase.execute())
            .thenThrow(networkException);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 네트워크 오류가 올바르게 처리되는지 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
        
        // 에러 메시지가 표시되는지 확인
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(networkException.userMessage), findsOneWidget);
      });
    });
  });
}
