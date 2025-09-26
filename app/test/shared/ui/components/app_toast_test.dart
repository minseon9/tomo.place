import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/components/toast_widget.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';
import '../../../utils/test_verifiers_util.dart';
import '../../../utils/test_wrappers_util.dart';
import '../../../utils/verifiers/style_verifiers.dart';

void main() {
  group('AppToast', () {
    testWidgets('메시지를 렌더링한다', (tester) async {
      await tester.pumpWidget(
        TestWrappersUtil.material(const AppToast(message: 'hello')),
      );

      TestRenderVerifier.expectText('hello');
      TestStyleVerifier.expectTextStyle(tester, 'hello', color: AppColors.tomoWhite);

      TestRenderVerifier.expectRenders<Container>();
      TestStyleVerifier.expectContainerDecoration(
        tester,
        find.byType(Container),
        color: AppColors.tomoBlack.withAlpha(128),
        borderRadius: 5,
      );
    });

    testWidgets('show가 SnackBar를 올바르게 표시한다', (tester) async {
      late BuildContext captured;

      await tester.pumpWidget(
        TestWrappersUtil.material(
          Builder(
            builder: (context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      AppToast.show(captured, 'snack');
      await tester.pump();

      TestRenderVerifier.expectSnackBar(message: 'snack');
      TestRenderVerifier.expectRenders<AppToast>();
    });
  });
}


