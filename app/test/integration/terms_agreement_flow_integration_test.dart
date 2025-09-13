import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/location_terms_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/privacy_policy_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/terms_of_service_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_agreement_modal.dart';
import 'package:tomo_place/shared/application/routes/routes.dart';

import '../utils/mock_factory/terms_mock_factory.dart';
import '../utils/widget/app_wrappers.dart';
import '../utils/widget/verifiers.dart';

class TestNavigatorObserver extends NavigatorObserver {
  final List<String> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route.settings.name ?? '');
    super.didPush(route, previousRoute);
  }
}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  group('Terms Agreement Flow Integration Tests', () {
    late MockVoidCallback mockOnDismiss;
    late MockNavigatorObserver mockNavigatorObserver;

    setUpAll(() {
      // Route<dynamic> 타입에 대한 fallback 값 등록
      registerFallbackValue(FakeRoute());
    });

    setUp(() {
      mockOnDismiss = TermsMockFactory.createVoidCallback();
      mockNavigatorObserver = TermsMockFactory.createNavigatorObserver();
    });

    // 통합 테스트 전용 Helper 함수들
    const Size defaultScreenSize = Size(390.0, 844.0);

    /// 약관 페이지들을 위한 라우트 맵
    Map<String, WidgetBuilder> getTermsRoutes() {
      return {
        Routes.termsOfService: (context) => const TermsOfServicePage(),
        Routes.privacyPolicy: (context) => const PrivacyPolicyPage(),
        Routes.locationTerms: (context) => const LocationTermsPage(),
      };
    }

    /// 모달 테스트 위젯 생성
    Widget createModalTestWidget({
      void Function(TermsAgreementResult)? onResult,
      Size? screenSize,
      bool includeRoutes = false,
    }) {
      final modal = TermsAgreementModal(
        onResult:
            onResult ??
            (result) {
              // 기본 콜백 - 테스트에서 필요시 오버라이드
            },
      );

      if (includeRoutes) {
        return AppWrappers.wrapWithMaterialAppWithSize(
          MaterialApp(home: modal, routes: getTermsRoutes()),
          screenSize: screenSize ?? defaultScreenSize,
        );
      }

      return AppWrappers.wrapWithMaterialAppWithSize(
        modal,
        screenSize: screenSize ?? defaultScreenSize,
      );
    }

    /// 약관 페이지 테스트 위젯 생성
    Widget createTermsPageTestWidget(Widget page) {
      return AppWrappers.wrapWithMaterialApp(page);
    }

    /// 모달 외부 터치를 위한 좌표 계산
    Offset calculateExternalTouchPoint() {
      // 화면 상단 모서리 (확실히 모달 외부)
      return const Offset(10, 10);
    }

    /// 모달 내부 터치를 위한 좌표 계산 (이벤트 전파 방지 테스트용)
    Offset calculateInternalTouchPoint(WidgetTester tester) {
      // "모두 동의합니다 !" 버튼과 x=0의 중간 지점 계산
      final agreeButton = find.text('모두 동의합니다 !');
      final agreeButtonRect = tester.getRect(agreeButton);

      // 버튼의 중앙 x 좌표와 화면 왼쪽 끝의 중간점
      final targetX = agreeButtonRect.center.dx / 2;
      final targetY = agreeButtonRect.center.dy;

      return Offset(targetX, targetY);
    }

    /// 모든 약관 텍스트가 표시되는지 검증
    void verifyAllTermsTextsDisplay() {
      const termsTexts = [
        '이용 약관 동의',
        '개인정보 보호 방침 동의',
        '위치정보 수집·이용 및 제3자 제공 동의',
        '만 14세 이상입니다',
      ];

      for (final text in termsTexts) {
        expect(find.text(text), findsOneWidget);
      }
    }

    /// 약관 라우트가 올바르게 정의되어 있는지 검증
    void verifyTermsRoutesDefined() {
      expect(Routes.termsOfService, equals('/terms/terms-of-service'));
      expect(Routes.privacyPolicy, equals('/terms/privacy-policy'));
      expect(Routes.locationTerms, equals('/terms/location-terms'));
    }

    /// 약관 라우트가 /terms/ 접두사를 가지는지 검증
    void verifyTermsRoutesPrefix() {
      const termsRoutes = [
        Routes.termsOfService,
        Routes.privacyPolicy,
        Routes.locationTerms,
      ];

      for (final route in termsRoutes) {
        expect(route, startsWith('/terms/'));
      }
    }

    /// 약관 라우트가 유효한 형식인지 검증
    void verifyTermsRoutesFormat() {
      const termsRoutes = [
        Routes.termsOfService,
        Routes.privacyPolicy,
        Routes.locationTerms,
      ];

      for (final route in termsRoutes) {
        expect(route, startsWith('/'));
        expect(route, matches(r'^/[a-zA-Z0-9\-/]*$'));
      }
    }

    /// 약관 라우트가 중복되지 않는지 검증
    void verifyTermsRoutesUnique() {
      const termsRoutes = [
        Routes.termsOfService,
        Routes.privacyPolicy,
        Routes.locationTerms,
      ];

      final uniqueRoutes = termsRoutes.toSet();
      expect(uniqueRoutes.length, equals(termsRoutes.length));
    }

    /// 성능 테스트를 위한 렌더링 시간 측정
    Future<void> measureRenderingTime(
      WidgetTester tester,
      Widget widget, {
      int maxMilliseconds = 1000,
    }) async {
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(maxMilliseconds));
    }

    group('모달 표시 및 닫기 플로우', () {
      testWidgets('모달이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnDismiss()).thenReturn(null);
        await tester.pumpWidget(createModalTestWidget());

        // When & Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsAgreementModal,
          expectedCount: 1,
        );
        WidgetVerifiers.verifyTextDisplays(
          text: '모두 동의합니다 !',
          expectedCount: 1,
        );
      });

      testWidgets('모든 동의 버튼 클릭 시 모달이 닫혀야 한다', (WidgetTester tester) async {
        // Given
        bool agreedCalled = false;
        await tester.pumpWidget(
          createModalTestWidget(
            onResult: (result) {
              if (result == TermsAgreementResult.agreed) {
                agreedCalled = true;
              }
            },
          ),
        );

        // When
        await tester.tap(find.text('모두 동의합니다 !'));
        await tester.pump();

        // Then
        expect(agreedCalled, isTrue);
      });

      testWidgets('외부 터치 시 모달이 닫혀야 한다', (WidgetTester tester) async {
        // Given
        bool dismissedCalled = false;
        await tester.pumpWidget(
          createModalTestWidget(
            onResult: (result) {
              if (result == TermsAgreementResult.dismissed) {
                dismissedCalled = true;
              }
            },
          ),
        );

        // When
        final externalPoint = calculateExternalTouchPoint();
        await tester.tapAt(externalPoint);
        await tester.pump();

        // Then
        expect(dismissedCalled, isTrue);
      });

      testWidgets('아래로 드래그 시 모달이 닫혀야 한다', (WidgetTester tester) async {
        // Given
        bool dismissedCalled = false;
        await tester.pumpWidget(
          createModalTestWidget(
            onResult: (result) {
              if (result == TermsAgreementResult.dismissed) {
                dismissedCalled = true;
              }
            },
          ),
        );

        // When
        final gestureDetector = find
            .byType(GestureDetector)
            .at(1); // 모달 컨테이너 GestureDetector
        await tester.drag(
          gestureDetector,
          const Offset(0, 50),
          warnIfMissed: false,
        );
        await tester.pump();

        // Then
        expect(dismissedCalled, isTrue);
      });
    });

    group('약관 항목 상호작용 플로우', () {
      testWidgets('약관 라우트가 올바르게 정의되어야 한다', (WidgetTester tester) async {
        // Given & When & Then
        verifyTermsRoutesDefined();
      });

      testWidgets('모든 약관 텍스트가 표시되어야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createModalTestWidget());

        // When & Then
        verifyAllTermsTextsDisplay();
      });
    });

    group('모달 상태 관리 플로우', () {
      testWidgets('모달 내부 터치 시 이벤트 전파가 방지되어야 한다', (WidgetTester tester) async {
        // Given
        bool dismissedCalled = false;
        await tester.pumpWidget(
          createModalTestWidget(
            onResult: (result) {
              if (result == TermsAgreementResult.dismissed) {
                dismissedCalled = true;
              }
            },
          ),
        );

        // When
        final internalPoint = calculateInternalTouchPoint(tester);
        await tester.tapAt(internalPoint);
        await tester.pump();

        // Then
        expect(dismissedCalled, isFalse);
      });

      testWidgets('모달이 안정적으로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When & Then
        await measureRenderingTime(tester, createModalTestWidget());
      });
    });

    group('사용자 경험 플로우', () {
      testWidgets('전체 약관 동의 플로우가 올바르게 작동해야 한다', (WidgetTester tester) async {
        // Given
        bool agreedCalled = false;
        await tester.pumpWidget(
          createModalTestWidget(
            onResult: (result) {
              if (result == TermsAgreementResult.agreed) {
                agreedCalled = true;
              }
            },
          ),
        );

        // When
        // 1. 모든 약관 항목 확인
        verifyAllTermsTextsDisplay();

        // 2. 모든 동의 버튼 클릭
        await tester.tap(find.text('모두 동의합니다 !'));
        await tester.pump();

        // Then
        expect(agreedCalled, isTrue);
      });
    });

    group('라우트 및 페이지 테스트', () {
      testWidgets('라우트 일관성이 유지되어야 한다', (WidgetTester tester) async {
        // Given & When & Then
        verifyTermsRoutesDefined();
        verifyTermsRoutesPrefix();
        verifyTermsRoutesFormat();
        verifyTermsRoutesUnique();
      });

      testWidgets('약관 페이지들이 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When & Then
        const termsPages = [
          TermsOfServicePage(),
          PrivacyPolicyPage(),
          LocationTermsPage(),
        ];

        const termsPageTitles = [
          '📌 이용 약관 동의',
          '📌 개인 정보 보호 방침 동의',
          '📌 위치 정보 수집·이용 및 제3자 제공 동의',
        ];

        for (int i = 0; i < termsPages.length; i++) {
          await tester.pumpWidget(createTermsPageTestWidget(termsPages[i]));

          WidgetVerifiers.verifyTextDisplays(
            text: termsPageTitles[i],
            expectedCount: 1,
          );
        }
      });
    });

    group('성능 및 안정성 테스트', () {
      testWidgets('반복적인 상호작용이 안정적으로 작동해야 한다', (WidgetTester tester) async {
        // Given
        int agreedCount = 0;
        int dismissedCount = 0;
        await tester.pumpWidget(
          createModalTestWidget(
            onResult: (result) {
              if (result == TermsAgreementResult.agreed) {
                agreedCount++;
              } else if (result == TermsAgreementResult.dismissed) {
                dismissedCount++;
              }
            },
          ),
        );

        // When
        // 여러 번 상호작용
        for (int i = 0; i < 3; i++) {
          // 동의 버튼 클릭
          await tester.tap(find.text('모두 동의합니다 !'));
          await tester.pump();

          // 모달 외부 터치로 닫기
          final externalPoint = calculateExternalTouchPoint();
          await tester.tapAt(externalPoint);
          await tester.pump();
        }

        // Then
        expect(agreedCount, equals(3));
        expect(dismissedCount, equals(3));
      });
    });
  });
}
