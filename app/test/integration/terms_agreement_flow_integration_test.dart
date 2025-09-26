import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/location_terms_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/privacy_policy_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/terms_of_service_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_agreement_modal.dart';

import '../utils/domains/test_terms_util.dart';
import '../utils/test_wrappers_util.dart';
import '../utils/test_verifiers_util.dart';

void main() {
  group('Terms Agreement Flow Integration Tests', () {
    late MockVoidCallback mockOnDismiss;
    late MockNavigatorObserver mockNavigatorObserver;

    setUpAll(() {
      registerFallbackValue(FakeRoute());
    });

    setUp(() {
      mockOnDismiss = TestTermsUtil.createVoidCallback();
      mockNavigatorObserver = TestTermsUtil.createNavigatorObserver();
    });

    Widget createModalTestWidget({
      void Function(TermsAgreementResult)? onResult,
      Size? screenSize,
      bool includeRoutes = false,
    }) {
      if (includeRoutes) {
        return TestTermsUtil.buildModalWithRoutes(
          onResult: onResult ?? (result) {
            switch (result) {
              case TermsAgreementResult.agreed:
                break;
              case TermsAgreementResult.dismissed:
                break;
            }
          },
          screenSize: screenSize ?? const Size(390.0, 844.0),
        );
      }

      return TestTermsUtil.buildModal(
        onResult: onResult ?? (result) {
          switch (result) {
            case TermsAgreementResult.agreed:
              break;
            case TermsAgreementResult.dismissed:
              break;
          }
        },
        screenSize: screenSize ?? const Size(390.0, 844.0),
      );
    }

    Widget createTermsPageTestWidget(Widget page) {
      return TestWrappersUtil.material(page);
    }

    group('모달 표시 및 닫기 플로우', () {
      testWidgets('모달이 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnDismiss()).thenReturn(null);
        await tester.pumpWidget(createModalTestWidget());

        // When & Then
        TestVerifiersUtil.expectRenders<TermsAgreementModal>();
        TestVerifiersUtil.expectText('모두 동의합니다 !');
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
        final externalPoint = TestTermsUtil.calculateExternalTouchPoint();
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
        TestTermsUtil.verifyTermsRoutesDefined();
      });

      testWidgets('모든 약관 텍스트가 표시되어야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createModalTestWidget());

        // When & Then
        TestTermsUtil.verifyAllTermsTextsDisplay();
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
        final internalPoint = TestTermsUtil.calculateInternalTouchPoint(tester);
        await tester.tapAt(internalPoint);
        await tester.pump();

        // Then
        expect(dismissedCalled, isFalse);
      });

      testWidgets('모달이 안정적으로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When & Then
        await TestTermsUtil.measureRenderingTime(tester, createModalTestWidget());
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
        TestTermsUtil.verifyAllTermsTextsDisplay();

        // 2. 모든 동의 버튼 클릭
        await tester.tap(TestTermsUtil.findAgreeAllButton());
        await tester.pump();

        // Then
        expect(agreedCalled, isTrue);
      });
    });

    group('라우트 및 페이지 테스트', () {
      testWidgets('라우트 일관성이 유지되어야 한다', (WidgetTester tester) async {
        // Given & When & Then
        TestTermsUtil.verifyTermsRoutesDefined();
        TestTermsUtil.verifyTermsRoutesPrefix();
        TestTermsUtil.verifyTermsRoutesFormat();
        TestTermsUtil.verifyTermsRoutesUnique();
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

          TestVerifiersUtil.expectText(termsPageTitles[i]);
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
          await tester.tap(TestTermsUtil.findAgreeAllButton());
          await tester.pump();

          // 모달 외부 터치로 닫기
          final externalPoint = TestTermsUtil.calculateExternalTouchPoint();
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
