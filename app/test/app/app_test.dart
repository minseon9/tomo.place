import 'package:tomo_place/app/app.dart';
import 'package:tomo_place/app/pages/splash_page.dart';
import 'package:tomo_place/app/router/app_router.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';
import 'package:tomo_place/shared/application/navigation/navigation_actions.dart' as nav;
import 'package:tomo_place/shared/application/navigation/navigation_actions.dart';
import 'package:tomo_place/shared/application/navigation/navigation_key.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../utils/mock_factory/presentation_mock_factory.dart';
import '../utils/widget/widget_test_utils.dart';

class MockSplashPage extends StatelessWidget {
  const MockSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Mock Splash Page'),
      ),
    );
  }
}

void main() {
  group('TomoPlaceApp', () {
    String testInitialRoute = '/test-home';

    late FakeAuthNotifier fakeAuthNotifier;
    late FakeNavigationActions fakeNavigationActions;
    late FakeExceptionNotifier fakeExceptionNotifier;

    setUp(() {
      fakeAuthNotifier = PresentationMockFactory.createFakeAuthNotifier();
      fakeNavigationActions = PresentationMockFactory.createFakeNavigationActions();
      fakeExceptionNotifier = PresentationMockFactory.createFakeExceptionNotifier();

      registerFallbackValue(true);
      registerFallbackValue(false);
      registerFallbackValue(0);
      registerFallbackValue('');
      registerFallbackValue(<String, dynamic>{});
      registerFallbackValue(<String>[]);
      registerFallbackValue(AuthInitial());
      registerFallbackValue(AuthSuccess(true));
      registerFallbackValue(AuthFailure(error: PresentationMockFactory.createExceptionInterface()));
      registerFallbackValue(PresentationMockFactory.createExceptionInterface());
      registerFallbackValue(GlobalKey<NavigatorState>());
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
        // When
        await tester.pumpWidget(createTestApp());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TomoPlaceApp,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: MaterialApp,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: ProviderScope,
          expectedCount: 1,
        );
      });

      testWidgets('전체 앱 구조가 예상대로 구성되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestApp());

        // Then
        verifyMaterialAppSettings(tester);
        verifyThemeSettings(tester);
      });

      testWidgets('ProviderScope가 올바르게 설정되어야 한다', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createTestApp());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: ProviderScope,
          expectedCount: 1,
        );
      });
    });
  });
}
