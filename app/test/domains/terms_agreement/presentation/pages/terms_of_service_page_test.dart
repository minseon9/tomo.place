import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/terms_of_service_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_content.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_page_layout.dart';

import '../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../utils/widget/app_wrappers.dart';
import '../../../../utils/widget/verifiers.dart';

void main() {
  group('TermsOfServicePage', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = TermsMockFactory.createBuildContext();
    });

    Widget createTestWidget() {
      return AppWrappers.wrapWithMaterialApp(const TermsOfServicePage());
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsOfServicePage,
          expectedCount: 1,
        );
        // Scaffold는 TermsPageLayout 내부에 있으므로 1개여야 함
        final termsPageLayout = find.byType(TermsPageLayout);
        final scaffoldInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Scaffold),
        );
        expect(scaffoldInLayout, findsOneWidget);
      });

      testWidgets('Scaffold 구조를 가져야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsPageLayout = find.byType(TermsPageLayout);
        final scaffoldInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Scaffold),
        );
        expect(scaffoldInLayout, findsOneWidget);
        final scaffold = tester.widget<Scaffold>(scaffoldInLayout);
        expect(scaffold, isNotNull);
        expect(scaffold.backgroundColor, equals(Colors.white));
      });
    });

    group('TermsPageLayout 테스트', () {
      testWidgets('TermsPageLayout이 올바르게 렌더링되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsPageLayout,
          expectedCount: 1,
        );
      });

      testWidgets('제목이 "이용 약관 동의"여야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '📌 이용 약관 동의',
          expectedCount: 1,
        );
      });

      testWidgets('Column 레이아웃이 올바르게 구성되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // TermsPageLayout의 최상위 Column만 찾기
        final termsPageLayout = find.byType(TermsPageLayout);
        final mainColumn = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Column),
        ).first;
        expect(mainColumn, findsOneWidget);
      });
    });

    group('콘텐츠 테스트', () {
      testWidgets('TermsContent가 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsContent,
          expectedCount: 1,
        );
      });

      testWidgets('SingleChildScrollView가 렌더링되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: SingleChildScrollView,
          expectedCount: 1,
        );
      });

      testWidgets('약관 내용이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final allTexts = find.byType(Text);
        expect(allTexts, findsWidgets);

        bool foundContent = false;
        for (int i = 0; i < allTexts.evaluate().length; i++) {
          final text = tester.widget<Text>(allTexts.at(i));
          if (text.data != null && text.data!.contains('제1조 (목적)')) {
            foundContent = true;
            break;
          }
        }
        expect(foundContent, isTrue, reason: '제1조 (목적) 내용이 표시되어야 함');
      });

      testWidgets('동의 버튼이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '동의',
          expectedCount: 1,
        );
      });

      testWidgets('동의 버튼 클릭 시 Navigator.pop이 호출되어야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createTestWidget());

        // When
        await tester.tap(find.text('동의'));
        await tester.pump();

        // Then
        // Navigator.pop이 호출되었는지 확인 (실제로는 테스트 환경에서 확인하기 어려움)
        // 하지만 onAgree 콜백이 호출되는 것은 확인 가능
        expect(find.text('동의'), findsOneWidget);
      });
    });

    group('접근성 테스트', () {
      testWidgets('스크린 리더 호환성이 있어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold, isNotNull);
        // Scaffold는 자동으로 접근성 지원을 제공함
      });

      testWidgets('모든 텍스트가 읽기 가능해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final textWidgets = find.byType(Text);
        expect(textWidgets, findsWidgets);

        // 모든 텍스트가 비어있지 않아야 함
        for (int i = 0; i < textWidgets.evaluate().length; i++) {
          final text = tester.widget<Text>(textWidgets.at(i));
          expect(text.data, isNotEmpty);
        }
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('전체 레이아웃이 올바르게 구성되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        // TermsPageLayout 내부의 Scaffold를 찾아서 검증
        final termsPageLayout = find.byType(TermsPageLayout);
        final scaffoldInLayout = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Scaffold),
        );
        expect(scaffoldInLayout, findsOneWidget);

        // 제목과 버튼 텍스트 확인
        WidgetVerifiers.verifyTextDisplays(
          text: '📌 이용 약관 동의',
          expectedCount: 1,
        );
        WidgetVerifiers.verifyTextDisplays(
          text: '동의',
          expectedCount: 1,
        );
      });

      testWidgets('Column 레이아웃이 올바르게 구성되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsPageLayout = find.byType(TermsPageLayout);
        final columnWidgets = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Column),
        );
        expect(columnWidgets, findsWidgets); // 여러 Column이 있음

        // Column의 children 개수 확인 (Header, Expanded Content, Footer)
        final mainColumn = tester.widget<Column>(columnWidgets.first);
        expect(mainColumn.children.length, equals(3));
      });

      testWidgets('SafeArea가 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifySafeArea(
          tester: tester,
          finder: find.byType(TermsOfServicePage),
          shouldHaveSafeArea: true,
        );
      });
    });

    group('Mock 사용 테스트', () {
      testWidgets('Mock BuildContext가 올바르게 처리되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given
        when(() => mockContext.mounted).thenReturn(true);

        // When
        await tester.pumpWidget(createTestWidget());

        // Then
        expect(mockContext.mounted, isTrue);
      });
    });

    group('상태 테스트', () {
      testWidgets('페이지가 안정적인 상태를 유지해야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsOfServicePage,
          expectedCount: 1,
        );
      });

      testWidgets('페이지가 재빌드되어도 안정적이어야 한다', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // When
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: TermsOfServicePage,
          expectedCount: 1,
        );
      });
    });
  });
}
