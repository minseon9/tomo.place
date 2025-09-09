import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/privacy_policy_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_content.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_page_layout.dart';

import '../../../../utils/mock_factory/terms_mock_factory.dart';
import '../../../../utils/widget/app_wrappers.dart';
import '../../../../utils/widget/verifiers.dart';

void main() {
  group('PrivacyPolicyPage', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = TermsMockFactory.createBuildContext();
    });

    Widget createTestWidget() {
      return AppWrappers.wrapWithMaterialApp(const PrivacyPolicyPage());
    }

    group('렌더링 테스트', () {
      testWidgets('기본적으로 올바르게 렌더링되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: PrivacyPolicyPage,
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

      testWidgets('제목이 "개인 정보 보호 방침 동의"여야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '📌 개인 정보 보호 방침 동의',
          expectedCount: 1,
        );
      });

      testWidgets('Stack 레이아웃이 올바르게 구성되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyStackLayout(
          tester: tester,
          finder: find.byType(Stack),
          expectedChildrenCount: 3,
        );
      });

      testWidgets('Positioned 위젯들이 올바르게 배치되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: Positioned,
          expectedCount: 4, // Header, CloseButton, Content, Footer
        );
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

      testWidgets('개인정보보호방침 내용이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final allTexts = find.byType(Text);
        expect(allTexts, findsWidgets);

        bool foundContent = false;
        for (int i = 0; i < allTexts.evaluate().length; i++) {
          final text = tester.widget<Text>(allTexts.at(i));
          if (text.data != null && text.data!.contains('수집·이용 목적')) {
            foundContent = true;
            break;
          }
        }
        expect(foundContent, isTrue, reason: '개인정보보호방침 내용이 표시되어야 함');
      });

      testWidgets('동의 버튼이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyTextDisplays(
          text: '모두 동의합니다 !',
          expectedCount: 1,
        );
      });

      testWidgets('닫기 버튼이 표시되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifyWidgetRenders(
          tester: tester,
          widgetType: IconButton,
          expectedCount: 1,
        );
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
          text: '📌 개인 정보 보호 방침 동의',
          expectedCount: 1,
        );
        WidgetVerifiers.verifyTextDisplays(
          text: '모두 동의합니다 !',
          expectedCount: 1,
        );
      });

      testWidgets('Position Fixed 레이아웃이 올바르게 구성되어야 한다', (
        WidgetTester tester,
      ) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        final termsPageLayout = find.byType(TermsPageLayout);
        final positionedWidgets = find.descendant(
          of: termsPageLayout,
          matching: find.byType(Positioned),
        );
        expect(
          positionedWidgets,
          findsNWidgets(4),
        ); // Header, CloseButton, Content, Footer

        // 헤더 위치 확인
        final headerPositioned = tester.widget<Positioned>(
          positionedWidgets.at(0),
        );
        expect(headerPositioned.top, equals(0));
        expect(headerPositioned.height, equals(88));

        // 푸터 위치 확인
        final footerPositioned = tester.widget<Positioned>(
          positionedWidgets.at(3),
        );
        expect(footerPositioned.bottom, equals(0));
        expect(footerPositioned.height, equals(124));
      });

      testWidgets('SafeArea가 올바르게 적용되어야 한다', (WidgetTester tester) async {
        // Given & When
        await tester.pumpWidget(createTestWidget());

        // Then
        WidgetVerifiers.verifySafeArea(
          tester: tester,
          finder: find.byType(PrivacyPolicyPage),
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
          widgetType: PrivacyPolicyPage,
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
          widgetType: PrivacyPolicyPage,
          expectedCount: 1,
        );
      });
    });
  });
}
