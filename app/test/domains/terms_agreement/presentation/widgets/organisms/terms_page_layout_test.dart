import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_content.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_page_layout.dart';

import '../../../../../utils/domains/test_terms_util.dart';
import '../../../../../utils/test_actions_util.dart';
import '../../../../../utils/test_wrappers_util.dart';
import '../../../../../utils/verifiers/test_render_verifier.dart';
import '../../../../../utils/verifiers/test_style_verifier.dart';

class _OnAgreeMock extends Mock {
  void call();
}

void main() {
  group('TermsPageLayout', () {
    late _OnAgreeMock onAgree;

    setUp(() {
      onAgree = _OnAgreeMock();
    });

    Widget createTestWidget({
      String? title,
      Map<String, String>? contentMap,
      VoidCallback? onAgreeCallback,
    }) {
      return TestWrappersUtil.material(
        TermsPageLayout(
          title: title ?? TestTermsUtil.termsTitle,
          contentMap: contentMap ?? TestTermsUtil.termsContent(),
          onAgree: onAgreeCallback ?? onAgree.call,
        ),
      );
    }

    testWidgets('Scaffold와 SafeArea 렌더링', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectRenders<TermsPageLayout>();
      final scaffold = find.descendant(
        of: find.byType(TermsPageLayout),
        matching: find.byType(Scaffold),
      );
      expect(scaffold, findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('헤더, 콘텐츠, 푸터 레이아웃 구성', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final columnFinder = find.descendant(
        of: find.byType(TermsPageLayout),
        matching: find.byType(Column),
      );
      expect(columnFinder, findsWidgets);
      final mainColumn = tester.widget<Column>(columnFinder.first);
      expect(mainColumn.children.length, equals(3));
    });

    testWidgets('헤더 컨테이너 스타일을 검증', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final containerFinder = find.descendant(
        of: find.byType(TermsPageLayout),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsWidgets);
      TestStyleVerifier.expectContainerDecoration(
        tester,
        containerFinder.first,
      );
    });

    testWidgets('콘텐츠 영역은 Expanded+SingleChildScrollView', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Expanded), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      TestRenderVerifier.expectRenders<TermsContent>();
    });

    testWidgets('길어진 내용도 스크롤 가능', (tester) async {
      final longContent = TestTermsUtil.generateLargeContent();
      await tester.pumpWidget(createTestWidget(contentMap: longContent));

      await TestActionsUtil.scrollAndSettle(
        tester,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );

      TestRenderVerifier.expectRenders<TermsContent>();
    });

    testWidgets('테마 텍스트 확인', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectText('📌 ${TestTermsUtil.termsTitle}');
      TestRenderVerifier.expectText('동의');
    });

    testWidgets('동의 버튼 탭 시 콜백 호출', (tester) async {
      when(onAgree.call).thenReturn(null);
      await tester.pumpWidget(createTestWidget(onAgreeCallback: onAgree.call));

      await TestActionsUtil.tapTextAndSettle(tester, '동의');

      verify(onAgree.call).called(1);
    });

    testWidgets('콜백 null이어도 탭 시 에러 없음', (tester) async {
      await tester.pumpWidget(createTestWidget(onAgreeCallback: null));

      await TestActionsUtil.tapTextAndSettle(tester, '동의');

      TestRenderVerifier.expectText('동의');
    });
  });
}
