import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_content.dart';

import '../../../../../utils/domains/test_terms_util.dart';
import '../../../../../utils/test_wrappers_util.dart';
import '../../../../../utils/test_responsive_util.dart';
import '../../../../../utils/test_actions_util.dart';
import '../../../../../utils/verifiers/test_render_verifier.dart';
import '../../../../../utils/verifiers/test_style_verifier.dart';

void main() {
  group('TermsContent', () {
    Widget createTestWidget({Map<String, String>? contentMap, Size? screenSize}) {
      return TestWrappersUtil.withScreenSize(
        Scaffold(
          body: SizedBox(
            height: 400,
            child: TermsContent(
              contentMap: contentMap ?? TestTermsUtil.termsContent(),
            ),
          ),
        ),
        screenSize: screenSize,
      );
    }

    testWidgets('스크롤과 Column 구조가 렌더링된다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectRenders<TermsContent>();
      TestRenderVerifier.expectRenders<SingleChildScrollView>();
      final columnFinder = find.descendant(
        of: find.byType(TermsContent),
        matching: find.byType(Column),
      );
      expect(columnFinder, findsWidgets);
      final column = tester.widget<Column>(columnFinder.first);
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));
    });

    testWidgets('제목과 본문 텍스트가 표시된다', (tester) async {
      final content = TestTermsUtil.termsContent();
      await tester.pumpWidget(createTestWidget(contentMap: content));

      for (final entry in content.entries) {
        TestRenderVerifier.expectText(entry.key);
        TestRenderVerifier.expectText(entry.value);
      }
    });

    testWidgets('제목 Typography 적용', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final title = TestTermsUtil.termsContent().keys.first;
      final text = tester.widget<Text>(find.text(title));
      final style = text.style;
      expect(style?.color, equals(const Color(0xFF212121)));
      expect(style?.letterSpacing, equals(-0.4));
    });

    testWidgets('본문 Typography 적용', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final body = TestTermsUtil.termsContent().values.first;
      final text = tester.widget<Text>(find.text(body));
      final style = text.style;
      expect(style?.color, equals(const Color(0xFF212121)));
      expect(style?.letterSpacing, equals(0.5));
      expect(style?.height, equals(1.2));
    });

    testWidgets('스크롤이 가능하다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await TestActionsUtil.scrollAndSettle(
        tester,
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );

      TestRenderVerifier.expectRenders<SingleChildScrollView>();
    });

    testWidgets('다양한 내용도 렌더링된다', (tester) async {
      final map = TestTermsUtil.privacyContent();
      await tester.pumpWidget(createTestWidget(contentMap: map));

      for (final entry in map.entries) {
        TestRenderVerifier.expectText(entry.key);
        TestRenderVerifier.expectText(entry.value);
      }
    });

    testWidgets('모바일/태블릿 간격이 유지된다', (tester) async {
      final screenSizes = [
        TestResponsiveUtil.standardMobileSize,
        TestResponsiveUtil.standardTabletSize,
      ];

      for (final size in screenSizes) {
        await tester.pumpWidget(createTestWidget(screenSize: size));
        TestRenderVerifier.expectRenders<TermsContent>();
      }
    });
  });
}
