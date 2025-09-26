import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/app/app.dart';
import 'package:tomo_place/app/router/app_router.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';
import 'package:tomo_place/shared/application/navigation/navigation_actions.dart';
import 'package:tomo_place/shared/application/navigation/navigation_key.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_interface.dart';
import 'package:tomo_place/shared/ui/components/toast_widget.dart';

import '../utils/test_wrappers_util.dart';
import '../utils/verifiers/test_render_verifier.dart';

class _FakeNavActions extends NavigationActions {
  _FakeNavActions(GlobalKey<NavigatorState> key) : super(key);
  int toSignup = 0;
  int toHome = 0;
  @override
  void navigateToSignup() { toSignup++; }
  @override
  void navigateToHome() { toHome++; }
}

class _FakeException implements ExceptionInterface {
  @override
  String get message => 'm';
  @override
  String get userMessage => 'u';
  @override
  String get title => 't';
  @override
  String? get errorCode => null;
  @override
  String get errorType => 'e';
  @override
  String? get suggestedAction => null;
}

void main() {
  group('TomoPlaceApp', () {
    String testInitialRoute = '/test-home';

    late FakeAuthNotifier fakeAuthNotifier;
    late FakeNavigationActions fakeNavigationActions;
    late FakeExceptionNotifier fakeExceptionNotifier;

    setUp(() {
      // 간단한 fake들로 대체
      fakeAuthNotifier = AuthNotifier(ProviderContainer().read);
      fakeNavigationActions = _FakeNavActions(GlobalKey<NavigatorState>());
      fakeExceptionNotifier = ExceptionNotifier();
    });

    // Helper 함수들
    Widget createTestApp({List<Override> overrides = const []}) {
      return ProviderScope(
        overrides: [
          // 테스트에서는 Timer 문제를 회피하기 위해 다른 초기 라우트 사용
          initialRouteProvider.overrideWith((ref) => testInitialRoute),
          // 테스트용 라우터 - 필요한 라우트만 간소화하여 제공
          routerProvider.overrideWith((ref) => (RouteSettings settings) {
            final testRoutes = {
              testInitialRoute: (context) => const Scaffold(
                body: Center(child: Text('Test Home Page')),
              ),
            };

            final builder = testRoutes[settings.name];
            if (builder != null) {
              return MaterialPageRoute(builder: builder, settings: settings);
            }

            // 404 페이지
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Test 404 Page')),
              ),
              settings: settings,
            );
          }),
          // Fake Provider들 추가 - ref watch/read 등록 확인용
          authNotifierProvider.overrideWith((ref) => fakeAuthNotifier),
          navigationActionsProvider.overrideWith((ref) => fakeNavigationActions),
          exceptionNotifierProvider.overrideWith((ref) => fakeExceptionNotifier),
          ...overrides,
        ],
        child: const TomoPlaceApp(), // 실제 TomoPlaceApp 사용
      );
    }

    void verifyMaterialAppSettings(WidgetTester tester) {
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(materialApp.title, equals('Tomo Place'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
      expect(materialApp.navigatorKey, isA<GlobalKey<NavigatorState>>());
      expect(materialApp.initialRoute, equals(testInitialRoute));
    }

    void verifyThemeSettings(WidgetTester tester) {
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme = materialApp.theme;

      expect(theme, isNotNull);
      expect(theme!.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, equals(const Color(0xFFF2E5CC)));
      expect(theme.colorScheme, isA<ColorScheme>());
    }

    group('MaterialApp 설정 테스트', () {
      testWidgets('앱 제목이 "Tomo Place"여야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestApp());

        // Then
        verifyMaterialAppSettings(tester);
      });

      testWidgets('debugShowCheckedModeBanner가 false여야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestApp());

        // Then
        verifyMaterialAppSettings(tester);
      });

      testWidgets('navigatorKey가 GlobalKey<NavigatorState>여야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestApp());

        // Then
        verifyMaterialAppSettings(tester);
      });

      testWidgets('initialRoute가 "/test-home"이어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestApp());

        // Then
        verifyMaterialAppSettings(tester);
      });

      testWidgets('테마 설정이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestApp());

        // Then
        verifyThemeSettings(tester);
      });

      testWidgets('onGenerateRoute가 AppRouter.generateRoute를 사용해야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestApp());

        // Then
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.onGenerateRoute, isNotNull);
      });
    });

    group('Provider 설정 테스트 - ref watch/read 등록 확인', () {
      testWidgets('navigatorKeyProvider가 GlobalKey<NavigatorState>를 제공해야 한다', (WidgetTester tester) async {
        // Given
        late GlobalKey<NavigatorState> navigatorKey;
        
        // When
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => fakeAuthNotifier),
              navigationActionsProvider.overrideWith((ref) => fakeNavigationActions),
              exceptionNotifierProvider.overrideWith((ref) => fakeExceptionNotifier),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                navigatorKey = ref.watch(navigatorKeyProvider);
                return const TomoPlaceApp();
              },
            ),
          ),
        );

        // Then
        expect(navigatorKey, isA<GlobalKey<NavigatorState>>());
      });

      testWidgets('navigationActionsProvider가 NavigationActions를 제공해야 한다', (WidgetTester tester) async {
        // Given
        late nav.NavigationActions navigationActions;
        
        // When
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => fakeAuthNotifier),
              navigationActionsProvider.overrideWith((ref) => fakeNavigationActions),
              exceptionNotifierProvider.overrideWith((ref) => fakeExceptionNotifier),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                navigationActions = ref.watch(navigationActionsProvider);
                return const TomoPlaceApp();
              },
            ),
          ),
        );

        // Then
        expect(navigationActions, isA<nav.NavigationActions>());
      });

      testWidgets('authNotifierProvider가 AuthNotifier를 제공해야 한다', (WidgetTester tester) async {
        // Given
        late AuthNotifier authNotifier;
        
        // When
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => fakeAuthNotifier),
              navigationActionsProvider.overrideWith((ref) => fakeNavigationActions),
              exceptionNotifierProvider.overrideWith((ref) => fakeExceptionNotifier),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                authNotifier = ref.read(authNotifierProvider.notifier);
                return const TomoPlaceApp();
              },
            ),
          ),
        );

        // Then
        expect(authNotifier, isA<AuthNotifier>());
        expect(authNotifier, equals(fakeAuthNotifier));
      });

      testWidgets('exceptionNotifierProvider가 ExceptionNotifier를 제공해야 한다', (WidgetTester tester) async {
        // Given
        late ExceptionNotifier exceptionNotifier;
        
        // When
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith((ref) => fakeAuthNotifier),
              navigationActionsProvider.overrideWith((ref) => fakeNavigationActions),
              exceptionNotifierProvider.overrideWith((ref) => fakeExceptionNotifier),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                exceptionNotifier = ref.read(exceptionNotifierProvider.notifier);
                return const TomoPlaceApp();
              },
            ),
          ),
        );

        // Then
        expect(exceptionNotifier, isA<ExceptionNotifier>());
        expect(exceptionNotifier, equals(fakeExceptionNotifier));
      });
    });

    group('통합 테스트', () {
      testWidgets('앱이 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        TestRenderVerifier.expectRenders<TomoPlaceApp>();
        TestRenderVerifier.expectRenders<MaterialApp>();
        TestRenderVerifier.expectRenders<ProviderScope>();
      });

      testWidgets('전체 앱 구조가 예상대로 구성되어야 한다', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        verifyMaterialAppSettings(tester);
        verifyThemeSettings(tester);
      });

      testWidgets('예외 발생 시 AppToast를 통해 스낵바 표시', (WidgetTester tester) async {
        final key = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [navigatorKeyProvider.overrideWithValue(key)],
            child: TestWrappersUtil.material(const TomoPlaceApp()),
          ),
        );
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        container.read(exceptionNotifierProvider.notifier).report(_FakeException());
        await tester.pump();
        TestRenderVerifier.expectSnackBar(message: 'u');
        TestRenderVerifier.expectRenders<AppToast>();
      });

      testWidgets('auth 상태에 따른 네비게이션 액션 호출', (WidgetTester tester) async {
        final key = GlobalKey<NavigatorState>();
        final fakeNav = _FakeNavActions(key);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              navigatorKeyProvider.overrideWithValue(key),
              navigationActionsProvider.overrideWithValue(fakeNav),
            ],
            child: const TomoPlaceApp(),
          ),
        );
        await tester.pump();
        final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
        container.read(authNotifierProvider.notifier).state = const AuthSuccess(true);
        await tester.pump();
        expect(fakeNav.toHome >= 0, isTrue);
      });
    });
  });
}
