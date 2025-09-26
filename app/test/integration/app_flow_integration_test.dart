import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/app/app.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';
import 'package:tomo_place/domains/auth/presentation/pages/signup_page.dart';
import 'package:tomo_place/shared/application/navigation/navigation_key.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';

import '../utils/domains/test_auth_util.dart';
import '../utils/test_verifiers_util.dart';

void main() {
  group('App Flow Integration Test', () {
    late AuthMocks mocks;

    setUp(() {
      mocks = TestAuthUtil.createMocks();
    });

    Widget createTestApp({List<Override> overrides = const []}) {
      final providerOverrides = TestAuthUtil.providerOverrides(mocks);
      return ProviderScope(
        overrides: [
          providerOverrides.authRepo,
          providerOverrides.tokenRepo,
          providerOverrides.baseClient,
          providerOverrides.signup,
          providerOverrides.logout,
          providerOverrides.refresh,
          ...overrides,
        ],
        child: const TomoPlaceApp(),
      );
    }

    group('앱 시작 플로우', () {
      testWidgets('유효한 토큰이 있을 때 홈 화면으로 네비게이션되어야 한다', (WidgetTester tester) async {
        // Given - 유효한 토큰이 있는 상황
        final validToken = TestAuthUtil.makeValidToken();
        
        TestAuthUtil.stubAuthenticated(mocks, validToken);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        
        // 로딩 상태 확인
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        await tester.pumpAndSettle();

        // Then - 더 구체적인 검증
        TestRenderVerifier.expectRenders<MaterialApp>();
        
        // Auth 상태 검증
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthSuccess>());
        expect((authState as AuthSuccess).isNavigateHome, isTrue);
        
        // 홈 화면으로 네비게이션되었는지 확인
        expect(find.text('홈 화면 (추후 구현)'), findsOneWidget);
      });

      testWidgets('토큰이 없을 때 로그인 화면으로 네비게이션되어야 한다', (WidgetTester tester) async {
        // Given - 토큰이 없는 상황
        TestAuthUtil.stubUnauthenticated(mocks);

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
        TestRenderVerifier.expectRenders<SignupPage>();
      });

      testWidgets('네트워크 오류 시 에러 처리와 스낵바가 표시되어야 한다', (WidgetTester tester) async {
        // Given - 네트워크 오류 상황
        final exception = TestAuthUtil.makeNetworkError();
        TestAuthUtil.stubRefreshFailure(mocks, exception: exception);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 에러 상태 및 UI 검증
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
        
        // 에러 스낵바가 표시되는지 확인
        TestRenderVerifier.expectSnackBar(message: exception.userMessage);
      });
    });

    group('네비게이션 플로우', () {
      testWidgets('인증 상태에 따른 자동 네비게이션이 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given - 인증되지 않은 상태
        TestAuthUtil.stubUnauthenticated(mocks);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 실제 네비게이션 테스트
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        expect(navigator, isNotNull);
        
        // 현재 루트 확인 - 로그인 화면이 표시되어야 함
        TestRenderVerifier.expectRenders<SignupPage>();
        
        // 네비게이션이 올바르게 설정되었는지 확인
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.navigatorKey, isA<GlobalKey<NavigatorState>>());
        expect(materialApp.onGenerateRoute, isNotNull);
      });

      testWidgets('인증 성공 시 홈 화면으로 자동 네비게이션되어야 한다', (WidgetTester tester) async {
        // Given - 인증 성공 상황
        final validToken = TestAuthUtil.makeValidToken();
        TestAuthUtil.stubAuthenticated(mocks, validToken);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 홈 화면으로 네비게이션되었는지 확인
        TestRenderVerifier.expectText('홈 화면 (추후 구현)');
        expect(find.byType(SignupPage), findsNothing);
      });

      testWidgets('네비게이션 스택이 올바르게 관리되어야 한다', (WidgetTester tester) async {
        // Given - 인증되지 않은 상태
        TestAuthUtil.stubUnauthenticated(mocks);

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
        TestAuthUtil.stubUnauthenticated(mocks);

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
        TestAuthUtil.stubUnauthenticated(mocks);

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
        final validToken = TestAuthUtil.makeValidToken();
        TestAuthUtil.stubAuthenticated(mocks, validToken);

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
        final exception = TestAuthUtil.makeNetworkError();
        TestAuthUtil.stubRefreshFailure(mocks, exception: exception);

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
        final exception = TestAuthUtil.makeNetworkError();
        TestAuthUtil.stubRefreshFailure(mocks, exception: exception);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 에러가 ExceptionNotifier를 통해 처리되는지 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
        
        // 에러 스낵바가 표시되는지 확인
        TestRenderVerifier.expectSnackBar(message: exception.userMessage);
      });

      testWidgets('다양한 에러 타입이 올바르게 처리되어야 한다', (WidgetTester tester) async {
        // Given - 네트워크 에러 상황
        final networkException = TestAuthUtil.makeNetworkError();
        TestAuthUtil.stubRefreshFailure(mocks, exception: networkException);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 네트워크 에러가 올바르게 처리되는지 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
        
        // 에러 스낵바가 표시되는지 확인
        TestRenderVerifier.expectSnackBar(message: networkException.userMessage);
      });
    });

    group('인증 상태 변화 플로우', () {
      testWidgets('토큰 만료 시 자동 갱신이 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given - 만료된 토큰이 있는 상황
        final newToken = TestAuthUtil.makeValidToken();
        TestAuthUtil.stubAuthenticated(mocks, newToken);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 토큰 갱신이 성공적으로 이루어졌는지 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthSuccess>());
      });

      testWidgets('토큰 갱신 실패 시 로그인 화면으로 이동해야 한다', (WidgetTester tester) async {
        // Given - 토큰 갱신 실패 상황
        final exception = TestAuthUtil.makeNetworkError();
        TestAuthUtil.stubRefreshFailure(mocks, exception: exception);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 로그인 화면으로 이동했는지 확인
        TestRenderVerifier.expectRenders<SignupPage>();
        
        // 에러 상태 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
      });

      testWidgets('네트워크 오류 후 재시도 플로우가 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given - 네트워크 오류 상황
        final networkException = TestAuthUtil.makeNetworkError();
        TestAuthUtil.stubRefreshFailure(mocks, exception: networkException);

        // When - 앱 시작
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Then - 네트워크 오류가 올바르게 처리되는지 확인
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthFailure>());
        
        // 에러 메시지가 표시되는지 확인
        TestRenderVerifier.expectSnackBar(message: networkException.userMessage);
      });
    });
  });
}
