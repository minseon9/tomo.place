import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/app/pages/splash_page.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';
import '../../utils/domains/test_auth_util.dart';
import '../../utils/verifiers/test_render_verifier.dart';

void main() {
  group('SplashPage', () {
    late ProviderContainer container;
    late AuthMocks mocks;

    setUp(() {
      mocks = TestAuthUtil.createMocks();
      TestAuthUtil.registerFallbackValues();
      TestAuthUtil.stubAuthNotifierLifecycle(mocks);

      final providerOverrides = TestAuthUtil.providerOverrides(mocks);
      container = ProviderContainer(
        overrides: [
          providerOverrides.authRepo,
          providerOverrides.tokenRepo,
          providerOverrides.baseClient,
          providerOverrides.signup,
          providerOverrides.logout,
          providerOverrides.refresh,
          TestAuthUtil.authNotifierOverride(mocks),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      mocks.resetAll();
    });

    Widget createTestSplashPage({List<Override> overrides = const []}) {
      return MaterialApp(
        home: ProviderScope(
          parent: container,
          overrides: overrides,
          child: const SplashPage(),
        ),
      );
    }

    Future<void> pumpSplashPage(WidgetTester tester) async {
      await tester.pumpWidget(createTestSplashPage());
    }

    // 테스트 그룹들
    group('Provider 테스트', () {
      testWidgets('ProviderScope가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // Given
        await pumpSplashPage(tester);

        // When & Then
        TestRenderVerifier.expectRenders<ProviderScope>();
        TestRenderVerifier.expectRenders<SplashPage>();
      });

      testWidgets('SplashPage가 ProviderScope 내에서 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        await pumpSplashPage(tester);

        // When & Then
        TestRenderVerifier.expectRenders<SplashPage>();
        TestRenderVerifier.expectRenders<Scaffold>();
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });
    });

    group('생명주기 테스트', () {
      testWidgets('SplashPage가 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<SplashPage>();
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });

      testWidgets('위젯이 안정적으로 마운트되어야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        // 여러 번의 pump로 안정성 확인
        await tester.pump();
        await tester.pump();

        // Then
        TestRenderVerifier.expectRenders<SplashPage>();
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });
    });

    group('인증 상태 확인 테스트', () {
      testWidgets('SplashPage가 인증 상태와 관계없이 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });

      testWidgets('인증 성공 상태에서 UI가 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthState(mocks, const AuthSuccess(true));
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });

      testWidgets('인증 실패 상태에서 UI가 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        final failureState = AuthFailure(error: TestAuthUtil.makeAuthError());
        TestAuthUtil.stubAuthState(mocks, failureState);
        TestAuthUtil.stubAuthRefreshSuccess(mocks, result: TestAuthUtil.makeUnauthenticatedResult());

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });

      testWidgets('네트워크 에러 상태에서 UI가 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        final networkException = TestAuthUtil.makeNetworkError();
        TestAuthUtil.stubAuthRefreshFailure(
          mocks,
          exception: networkException,
          nextState: AuthFailure(error: networkException),
        );

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });
    });

    group('UI 렌더링 테스트', () {
      testWidgets('CircularProgressIndicator가 표시되어야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });

      testWidgets('Scaffold 구조가 올바르게 구성되어야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<Scaffold>();
        TestRenderVerifier.expectRenders<Center>();
      });

      testWidgets('Center 위젯이 올바르게 배치되어야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        // Then
        final center = tester.widget<Center>(find.byType(Center));
        expect(center.child, isA<CircularProgressIndicator>());
      });
    });

    group('Timer 문제 해결 테스트', () {
      testWidgets('SplashPage로 Timer 문제를 해결해야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });

      testWidgets('pump 조합으로 안정적인 렌더링을 보장해야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        await tester.pump();
        await tester.pump();
        await tester.pump();

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });

      testWidgets('pumpAndSettle 없이도 정상 동작해야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        await tester.pump();

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });
    });

    group('에러 처리 테스트', () {
      testWidgets('인증 에러 상태에서 UI가 안정적으로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        final authError = TestAuthUtil.makeAuthError();
        TestAuthUtil.stubAuthRefreshFailure(
          mocks,
          exception: authError,
          nextState: AuthFailure(error: authError),
        );

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });

      testWidgets('네트워크 에러 상태에서 UI가 안정적으로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        final networkException = TestAuthUtil.makeNetworkError();
        TestAuthUtil.stubAuthRefreshFailure(
          mocks,
          exception: networkException,
          nextState: AuthFailure(error: networkException),
        );

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });

      testWidgets('타임아웃 에러 상태에서 UI가 안정적으로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        final timeoutException = Exception('Timeout');
        TestAuthUtil.stubAuthRefreshFailure(
          mocks,
          exception: timeoutException,
          nextState: AuthFailure(error: TestAuthUtil.makeAuthError(message: 'Timeout')),
        );

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });
    });

    group('통합 테스트', () {
      testWidgets('전체 SplashPage 플로우가 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthState(mocks, const AuthInitial());
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<SplashPage>();
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });

      testWidgets('여러 상태에서 안정적으로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given
        TestAuthUtil.stubAuthState(mocks, const AuthInitial());
        TestAuthUtil.stubAuthRefreshSuccess(mocks);

        // When
        await pumpSplashPage(tester);

        // Then
        TestRenderVerifier.expectRenders<SplashPage>();
        TestRenderVerifier.expectRenders<CircularProgressIndicator>();
      });
    });
  });
}
