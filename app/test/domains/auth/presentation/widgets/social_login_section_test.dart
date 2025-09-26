import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_button.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_section.dart';

import '../../../../utils/test_wrappers_util.dart';
import '../../../../utils/test_actions_util.dart';
import '../../../../utils/verifiers/test_render_verifier.dart';

class _OnProviderPressedMock extends Mock {
  void call(SocialProvider provider);
}

void main() {
  group('SocialLoginSection', () {
    Widget buildSection(void Function(SocialProvider provider)? onPressed) {
      return TestWrappersUtil.material(
        SocialLoginSection(onProviderPressed: onPressed),
      );
    }

    testWidgets('세 개의 SocialLoginButton을 렌더링', (tester) async {
      await tester.pumpWidget(buildSection((_) {}));

      TestRenderVerifier.expectRenders<SocialLoginButton>(count: 3);
    });

    testWidgets('버튼 순서는 Kakao -> Apple -> Google', (tester) async {
      await tester.pumpWidget(buildSection((_) {}));

      final buttons = tester.widgetList<SocialLoginButton>(find.byType(SocialLoginButton)).toList();
      expect(buttons[0].provider, SocialProvider.kakao);
      expect(buttons[1].provider, SocialProvider.apple);
      expect(buttons[2].provider, SocialProvider.google);
    });

    testWidgets('Google 버튼 탭 시 콜백 호출', (tester) async {
      final mock = _OnProviderPressedMock();
      when(() => mock(SocialProvider.google)).thenReturn(null);

      await tester.pumpWidget(buildSection(mock.call));

      final googleButton = find.byType(SocialLoginButton).at(2);
      await TestActionsUtil.tapFinderAndSettle(tester, googleButton);

      verify(() => mock(SocialProvider.google)).called(1);
    });

    testWidgets('콜백이 없으면 Google 버튼도 비활성화', (tester) async {
      await tester.pumpWidget(buildSection(null));

      final googleButton = tester.widget<SocialLoginButton>(find.byType(SocialLoginButton).at(2));
      expect(googleButton.onPressed, isNull);
    });
  });
}
