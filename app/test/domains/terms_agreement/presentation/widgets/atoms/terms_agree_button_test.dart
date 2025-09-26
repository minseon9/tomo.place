import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/terms_agree_button.dart';

import '../../../../../utils/domains/test_terms_util.dart';
import '../../../../../utils/test_actions_util.dart';
import '../../../../../utils/test_wrappers_util.dart';
import '../../../../../utils/verifiers/test_render_verifier.dart';
import '../../../../../utils/verifiers/test_style_verifier.dart';

void main() {
  group('TermsAgreeButton', () {
    late TermsMocks mocks;

    setUp(() {
      mocks = TestTermsUtil.createMocks();
    });

    Widget createTestWidget({VoidCallback? onPressed}) {
      return TestWrappersUtil.material(
        TermsAgreeButton(onPressed: onPressed ?? () {}),
      );
    }

    testWidgets('버튼과 텍스트가 렌더링된다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectRenders<TermsAgreeButton>();
      TestRenderVerifier.expectText(TestTermsUtil.agreeAllButton);
    });

    testWidgets('컨테이너가 존재하고 스타일이 적용된다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final containerFinder = find.byType(Container).first;
      TestStyleVerifier.expectContainerDecoration(
        tester,
        containerFinder,
      );
    });

    testWidgets('텍스트 스타일이 유지된다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final text = tester.widget<Text>(find.text(TestTermsUtil.agreeAllButton));
      expect(text.style, isNotNull);
      expect(text.style?.letterSpacing, equals(-0.28));
    });

    testWidgets('InkWell이 터치 영역을 제공한다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, isNotNull);
    });

    testWidgets('탭 시 콜백이 호출된다', (tester) async {
      when(() => mocks.onPressed()).thenReturn(null);
      await tester.pumpWidget(
        createTestWidget(onPressed: mocks.onPressed.call),
      );

      await TestActionsUtil.tapFinderAndSettle(tester, find.byType(InkWell));

      verify(() => mocks.onPressed()).called(1);
    });

    testWidgets('탭하지 않으면 콜백이 호출되지 않는다', (tester) async {
      when(() => mocks.onPressed()).thenReturn(null);
      await tester.pumpWidget(
        createTestWidget(onPressed: mocks.onPressed.call),
      );

      verifyNever(() => mocks.onPressed());
    });
  });
}
