import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/expand_icon.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_agreement_item.dart';

import '../../../../../utils/domains/test_terms_util.dart';
import '../../../../../utils/test_actions_util.dart';
import '../../../../../utils/test_wrappers_util.dart';
import '../../../../../utils/verifiers/test_render_verifier.dart';
import '../../../../../utils/verifiers/test_style_verifier.dart';

void main() {
  group('TermsAgreementItem', () {
    late TermsMocks mocks;

    setUp(() {
      mocks = TestTermsUtil.createMocks();
    });

    Widget createTestWidget({
      String title = TestTermsUtil.termsTitle,
      bool isChecked = true,
      bool hasExpandIcon = true,
      VoidCallback? onExpandTap,
    }) {
      return TestWrappersUtil.material(
        TermsAgreementItem(
          title: title,
          isChecked: isChecked,
          hasExpandIcon: hasExpandIcon,
          onExpandTap: onExpandTap,
        ),
      );
    }

    testWidgets('체크박스, 텍스트, 확장아이콘이 렌더링된다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectRenders<TermsAgreementItem>();
      TestRenderVerifier.expectRenders<Row>();
      TestRenderVerifier.expectText(TestTermsUtil.termsTitle);
    });

    testWidgets('확장 아이콘이 조건부로 렌더링된다', (tester) async {
      await tester.pumpWidget(createTestWidget(hasExpandIcon: true));
      TestRenderVerifier.expectRenders<TermsExpandIcon>();

      await tester.pumpWidget(createTestWidget(hasExpandIcon: false));
      expect(find.byType(TermsExpandIcon), findsNothing);
    });

    testWidgets('제목 텍스트는 letterSpacing -0.24', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final text = tester.widget<Text>(find.text(TestTermsUtil.termsTitle));
      expect(text.style?.letterSpacing, equals(-0.24));
    });

    testWidgets('긴 제목도 정상 표시', (tester) async {
      const longTitle = '긴 제목 테스트를 위한 문구입니다.';
      await tester.pumpWidget(createTestWidget(title: longTitle));

      TestRenderVerifier.expectText(longTitle);
    });

    testWidgets('확장 탭 콜백이 호출된다', (tester) async {
      when(() => mocks.onPressed()).thenReturn(null);
      await tester.pumpWidget(
        createTestWidget(
          onExpandTap: mocks.onPressed.call,
        ),
      );

      await TestActionsUtil.tapFinderAndSettle(
        tester,
        find.byType(GestureDetector).first,
      );

      verify(() => mocks.onPressed()).called(1);
    });

    testWidgets('확장 콜백이 null이어도 탭 시 에러 없다', (tester) async {
      await tester.pumpWidget(createTestWidget(onExpandTap: null));

      await TestActionsUtil.tapFinderAndSettle(
        tester,
        find.byType(GestureDetector).first,
      );
    });
  });
}
