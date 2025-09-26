import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/location_terms_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_content.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_page_layout.dart';

import '../../../../utils/domains/test_terms_util.dart';
import '../../../../utils/test_wrappers_util.dart';
import '../../../../utils/verifiers/test_render_verifier.dart';

void main() {
  group('LocationTermsPage', () {
    Widget createTestWidget() {
      return TestWrappersUtil.material(const LocationTermsPage());
    }

    testWidgets('Scaffold와 기본 구조 렌더링', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectRenders<LocationTermsPage>();
      final scaffoldFinder = find.descendant(
        of: find.byType(TermsPageLayout),
        matching: find.byType(Scaffold),
      );
      expect(scaffoldFinder, findsOneWidget);
    });

    testWidgets('제목과 내용 텍스트 표시', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectText('📌 위치 정보 수집·이용 및 제3자 제공 동의');
      TestRenderVerifier.expectRenders<TermsContent>();
    });

    testWidgets('동의 버튼 텍스트 표시', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectText('동의');
    });
  });
}
