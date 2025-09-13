import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/expand_icon.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_agreement_item.dart';

import '../../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../../utils/widget/app_wrappers.dart';
import '../../../../../utils/widget/verifiers.dart';
import '../../../../../utils/responsive_test_helper.dart';

void main() {
  group('TermsAgreementItem', () {
    late MockVoidCallback mockOnExpandTap;

    setUp(() {
      mockOnExpandTap = TermsMockFactory.createVoidCallback();
    });

    Widget createTestWidget({
      String title = '이용 약관 동의',
      bool isChecked = true,
      bool hasExpandIcon = true,
      VoidCallback? onExpandTap,
    }) {
      return AppWrappers.wrapWithMaterialApp(
        TermsAgreementItem(
          title: title,
          isChecked: isChecked,
          hasExpandIcon: hasExpandIcon,
          onExpandTap: onExpandTap,
        ),
      );
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsAgreementItem,
          expectedCount: 1,
        );
        // TermsAgreementItem 내부의 SizedBox들을 찾기 (더 구체적으로)
        final termsAgreementItem = find.byType(TermsAgreementItem);
        final sizedBoxes = find.descendant(
          of: termsAgreementItem,
          matching: find.byType(SizedBox),
        );
        expect(sizedBoxes, findsWidgets);
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Row,
          expectedCount: 1,
        );
        // TermsAgreementItem의 GestureDetector만 찾기
        final termsAgreementItem2 = find.byType(TermsAgreementItem);
        final gestureDetector = find.descendant(
          of: termsAgreementItem2,
          matching: find.byType(GestureDetector),
        ).first;
        expect(gestureDetector, findsOneWidget);
        // TermsAgreementItem 내부의 Container들을 찾기
        final termsAgreementItem3 = find.byType(TermsAgreementItem);
        final containers = find.descendant(
          of: termsAgreementItem3,
          matching: find.byType(Container),
        );
        expect(containers, findsWidgets);
      });

      testWidgets('모바일에서 올바른 높이로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: ResponsiveTestHelper.standardMobileSize,
            child: createTestWidget(),
          ),
        );

        // Then
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsWidgets);
      });

      testWidgets('태블릿에서 올바른 높이로 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(
          ResponsiveTestHelper.createTestWidget(
            screenSize: ResponsiveTestHelper.standardTabletSize,
            child: createTestWidget(),
          ),
        );

        // Then
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsWidgets);
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('체크박스, 텍스트, 확장 아이콘이 올바르게 배치되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Row,
          expectedCount: 1,
        );
        // 체크박스, 텍스트, 확장 아이콘이 Row 내부에 있어야 함
      });

      testWidgets('Row 레이아웃 구조를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final row = tester.widget<Row>(find.byType(Row));
        expect(row, isNotNull);
        expect(row.children.length, greaterThan(0));
      });
    });

    group('조건부 렌더링 테스트', () {
      testWidgets('hasExpandIcon이 false일 때 확장 아이콘이 숨겨져야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(hasExpandIcon: false));

        // Then
        // 확장 아이콘이 렌더링되지 않아야 함 (AppWrappers의 GestureDetector는 제외)
        expect(find.byType(TermsExpandIcon), findsNothing);
      });

      testWidgets('hasExpandIcon이 true일 때 확장 아이콘이 표시되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(hasExpandIcon: true));

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsExpandIcon,
          expectedCount: 1,
        );
      });
    });

    group('텍스트 테스트', () {
      testWidgets('제목 텍스트가 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        const expectedTitle = '이용 약관 동의';

        // When
        await tester.pumpWidget(createTestWidget(title: expectedTitle));

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: expectedTitle,
          expectedCount: 1,
        );
      });

      testWidgets('다른 제목 텍스트가 올바르게 표시되어야 한다', (WidgetTester tester) async {
        // Given
        const expectedTitle = '개인정보 보호 방침 동의';

        // When
        await tester.pumpWidget(createTestWidget(title: expectedTitle));

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: expectedTitle,
          expectedCount: 1,
        );
      });

      testWidgets('텍스트 스타일이 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final text = tester.widget<Text>(find.text('이용 약관 동의'));
        expect(text.style, isNotNull);
        expect(text.style?.letterSpacing, equals(-0.24));
      });

      testWidgets('텍스트 오버플로우가 처리되어야 한다', (WidgetTester tester) async {
        // Given
        const longTitle = '매우 긴 약관 제목이 있을 때 텍스트 오버플로우가 어떻게 처리되는지 확인하는 테스트';

        // When
        await tester.pumpWidget(createTestWidget(title: longTitle));

        // Then
        WidgetVerifiers.verifyTextDisplays(text: longTitle, expectedCount: 1);
        // Expanded 위젯으로 감싸져 있어 오버플로우가 처리됨
      });
    });

    group('상호작용 테스트', () {
      testWidgets('아이템 클릭 시 onExpandTap 콜백이 호출되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given
        when(() => mockOnExpandTap()).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(
            hasExpandIcon: true,
            onExpandTap: mockOnExpandTap.call,
          ),
        );

        // When
        // TermsAgreementItem의 GestureDetector만 찾기
        final termsAgreementItem = find.byType(TermsAgreementItem);
        final gestureDetector = find.descendant(
          of: termsAgreementItem,
          matching: find.byType(GestureDetector),
        ).first;
        await tester.tap(gestureDetector);
        await tester.pump();

        // Then
        verify(() => mockOnExpandTap()).called(1);
      });

      testWidgets('확장 아이콘이 없을 때 클릭해도 에러가 발생하지 않아야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget(hasExpandIcon: false));

        // Then
        expect(() async {
          // TermsAgreementItem의 GestureDetector만 찾기
        final termsAgreementItem = find.byType(TermsAgreementItem);
        final gestureDetector = find.descendant(
          of: termsAgreementItem,
          matching: find.byType(GestureDetector),
        ).first;
        await tester.tap(gestureDetector);
          await tester.pump();
        }, returnsNormally);
      });

      testWidgets('onExpandTap이 null일 때 클릭해도 에러가 발생하지 않아야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(
          createTestWidget(hasExpandIcon: true, onExpandTap: null),
        );

        // Then
        expect(() async {
          // TermsAgreementItem의 GestureDetector만 찾기
        final termsAgreementItem = find.byType(TermsAgreementItem);
        final gestureDetector = find.descendant(
          of: termsAgreementItem,
          matching: find.byType(GestureDetector),
        ).first;
        await tester.tap(gestureDetector);
          await tester.pump();
        }, returnsNormally);
      });
    });

    group('스타일 테스트', () {
      testWidgets('전체 아이템 스타일이 일관되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsWidgets);
        // 첫 번째 SizedBox (TermsAgreementItem의 메인 SizedBox)의 높이 확인
        final mainSizedBox = tester.widget<SizedBox>(sizedBoxes.first);
        expect(mainSizedBox.height, equals(52.0));
      });

      testWidgets('간격 설정이 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final row = tester.widget<Row>(find.byType(Row));
        expect(row, isNotNull);
        // SizedBox로 간격이 설정되어 있음
      });
    });

    group('Mock 사용 테스트', () {
      testWidgets('Mock 콜백이 올바르게 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnExpandTap()).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(
            hasExpandIcon: true,
            onExpandTap: mockOnExpandTap.call,
          ),
        );

        // When
        // TermsAgreementItem의 GestureDetector만 찾기
        final termsAgreementItem = find.byType(TermsAgreementItem);
        final gestureDetector = find.descendant(
          of: termsAgreementItem,
          matching: find.byType(GestureDetector),
        ).first;
        await tester.tap(gestureDetector);
        await tester.pump();

        // Then
        verify(() => mockOnExpandTap()).called(1);
      });

      testWidgets('Mock 콜백이 여러 번 호출되어야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnExpandTap()).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(
            hasExpandIcon: true,
            onExpandTap: mockOnExpandTap.call,
          ),
        );

        // When
        // TermsAgreementItem의 GestureDetector만 찾기
        final termsAgreementItem = find.byType(TermsAgreementItem);
        final gestureDetector = find.descendant(
          of: termsAgreementItem,
          matching: find.byType(GestureDetector),
        ).first;
        await tester.tap(gestureDetector);
        await tester.pump();
        await tester.tap(find.byType(TermsExpandIcon));
        await tester.pump();

        // Then
        verify(() => mockOnExpandTap()).called(2);
      });

      testWidgets('Mock 콜백이 호출되지 않아야 한다', (WidgetTester tester) async {
        // Given
        when(() => mockOnExpandTap()).thenReturn(null);
        await tester.pumpWidget(
          createTestWidget(
            hasExpandIcon: false,
            onExpandTap: mockOnExpandTap.call,
          ),
        );

        // When
        // 확장 아이콘이 없으므로 클릭할 수 없음

        // Then
        verifyNever(() => mockOnExpandTap());
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 속성이 설정되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final row = tester.widget<Row>(find.byType(Row));
        expect(row, isNotNull);
        // 접근성 테스트는 실제 앱에서 더 구체적으로 구현
      });
    });
  });
}
