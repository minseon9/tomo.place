import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/expand_icon.dart';

import '../../../../../utils/test_wrappers_util.dart';
import '../../../../../utils/verifiers/test_render_verifier.dart';
import '../../../../../utils/verifiers/test_style_verifier.dart';

void main() {
  group('TermsExpandIcon', () {
    Widget createTestWidget() {
      return TestWrappersUtil.material(const TermsExpandIcon());
    }

    testWidgets('기본 렌더링이 이루어진다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectRenders<TermsExpandIcon>();
      TestRenderVerifier.expectRenders<Container>();
      TestRenderVerifier.expectRenders<SvgPicture>();
    });

    testWidgets('컨테이너 크기가 52x52', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final container = tester.widget<Container>(find.byType(Container));
      final constraints = container.constraints;
      expect(constraints?.maxWidth, equals(52));
      expect(constraints?.maxHeight, equals(52));
    });

    testWidgets('투명 배경 유지', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestStyleVerifier.expectContainerDecoration(
        tester,
        find.byType(Container),
        color: Colors.transparent,
      );
    });

    testWidgets('SVG 색상 필터가 존재', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.colorFilter, isNotNull);
    });

    testWidgets('제스처 핸들러가 존재하지 않는다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(GestureDetector), findsNothing);
    });
  });
}
