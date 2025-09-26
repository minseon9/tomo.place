import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/privacy_policy_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_content.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_page_layout.dart';

import '../../../../utils/domains/test_terms_util.dart';
import '../../../../utils/test_wrappers_util.dart';
import '../../../../utils/verifiers/test_render_verifier.dart';

void main() {
  group('PrivacyPolicyPage', () {
    Widget createTestWidget() {
      return TestWrappersUtil.material(const PrivacyPolicyPage());
    }

    testWidgets('페이지와 레이아웃 렌더링', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectRenders<PrivacyPolicyPage>();
      final scaffold = find.descendant(
        of: find.byType(TermsPageLayout),
        matching: find.byType(Scaffold),
      );
      expect(scaffold, findsOneWidget);
    });

    testWidgets('제목과 콘텐츠가 표시된다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectText('📌 개인 정보 보호 방침 동의');
      TestRenderVerifier.expectRenders<TermsContent>();
    });

    testWidgets('동의 버튼 텍스트 표시', (tester) async {
      await tester.pumpWidget(createTestWidget());

      TestRenderVerifier.expectText('동의');
    });
  });
}
