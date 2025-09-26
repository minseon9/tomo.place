import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_button.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';

import '../../../../utils/test_wrappers_util.dart';
import '../../../../utils/verifiers/test_render_verifier.dart';
import '../../../../utils/verifiers/test_style_verifier.dart';

void main() {
  group('SocialLoginButton', () {
    Widget buildButton(
      SocialProvider provider, {
      VoidCallback? onPressed,
      bool isLoading = false,
    }) {
      return TestWrappersUtil.material(
        SocialLoginButton(
          provider: provider,
          onPressed: onPressed,
          isLoading: isLoading,
        ),
      );
    }

    testWidgets('Google 버튼 렌더링과 텍스트', (tester) async {
      await tester.pumpWidget(buildButton(SocialProvider.google, onPressed: () {}));

      TestRenderVerifier.expectRenders<SocialLoginButton>();
      TestRenderVerifier.expectText('구글로 시작하기');
    });

    testWidgets('Apple 버튼은 비활성화 텍스트 스타일', (tester) async {
      await tester.pumpWidget(buildButton(SocialProvider.apple));

      TestRenderVerifier.expectText('애플로 시작하기 (준비 중)');
      TestStyleVerifier.expectTextStyle(
        tester,
        '애플로 시작하기 (준비 중)',
        color: AppColors.tomoDarkGray.withValues(alpha: 0.5),
      );
    });

    testWidgets('로딩 상태에서는 onPressed가 비활성화', (tester) async {
      await tester.pumpWidget(buildButton(SocialProvider.google, onPressed: () {}, isLoading: true));

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });
  });
}
