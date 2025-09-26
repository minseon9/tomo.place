import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';
import 'package:tomo_place/domains/auth/presentation/pages/signup_page.dart';
import 'package:tomo_place/domains/auth/presentation/widgets/social_login_section.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_agreement_modal.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/molecules/terms_agreement_item.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/atoms/terms_agree_button.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';

import '../../../../utils/domains/test_auth_util.dart';
import '../../../../utils/domains/test_terms_util.dart';
import '../../../../utils/test_actions_util.dart';
import '../../../../utils/test_wrappers_util.dart';
import '../../../../utils/verifiers/test_render_verifier.dart';
import '../../../../utils/test_exception_util.dart';

void main() {
  group('SignupPage', () {
    late AuthMocks authMocks;
    late MockExceptionNotifier exceptionNotifier;

    setUp(() {
      authMocks = TestAuthUtil.createMocks();
      exceptionNotifier = TestExceptionUtil.createMockNotifier();
      TestAuthUtil.stubSignupSuccess(
        authMocks,
        provider: SocialProvider.google,
        token: TestAuthUtil.makeValidToken(),
      );
    });

    Widget createWidget({Map<String, WidgetBuilder>? extraRoutes}) {
      final overrides = TestAuthUtil.providerOverrides(
        authMocks,
        exceptionNotifier: exceptionNotifier,
      );
      return ProviderScope(
        overrides: [
          overrides.authRepo,
          overrides.tokenRepo,
          overrides.baseClient,
          overrides.signup,
          overrides.logout,
          overrides.refresh,
          overrides.exceptionNotifier,
        ],
        child: TestWrappersUtil.createTestAppWithRouting(
          child: const SignupPage(),
          routes: extraRoutes,
        ),
      );
    }

    testWidgets('기본 레이아웃 렌더링', (tester) async {
      await tester.pumpWidget(createWidget());

      TestRenderVerifier.expectRenders<SignupPage>();
      TestRenderVerifier.expectRenders<Scaffold>();
      TestRenderVerifier.expectRenders<SafeArea>();
      TestRenderVerifier.expectRenders<SocialLoginSection>();
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('배경색은 AppColors.background', (tester) async {
      await tester.pumpWidget(createWidget());

      final scaffold = tester.widgetList<Scaffold>(find.byType(Scaffold)).last;
      expect(scaffold.backgroundColor, equals(AppColors.background));
    });

    group('이용약관 모달', () {
      Future<void> openModal(WidgetTester tester) async {
        await TestActionsUtil.tapTextAndSettle(tester, '구글로 시작하기');
        await tester.pumpAndSettle();
        TestRenderVerifier.expectRenders<TermsAgreementModal>();
      }

      testWidgets('모두 동의 버튼으로 모달 닫힘', (tester) async {
        await tester.pumpWidget(
          createWidget(extraRoutes: TestTermsUtil.routes()),
        );
        await openModal(tester);

        await TestActionsUtil.tapTextAndSettle(tester, TestTermsUtil.agreeAllButton);
        await tester.pumpAndSettle();
        expect(find.byType(TermsAgreementModal), findsNothing);
      });

      testWidgets('외부 탭으로 모달 닫힘', (tester) async {
        await tester.pumpWidget(
          createWidget(extraRoutes: TestTermsUtil.routes()),
        );
        await openModal(tester);

        final detector = find.descendant(
          of: find.byType(TermsAgreementModal),
          matching: find.byType(GestureDetector),
        ).first;
        await TestActionsUtil.tapFinderAndSettle(tester, detector);
        await tester.pumpAndSettle();

        expect(find.byType(TermsAgreementModal), findsNothing);
      });

      testWidgets('모달 항목과 버튼 렌더링', (tester) async {
        await tester.pumpWidget(createWidget(extraRoutes: TestTermsUtil.routes()));
        await openModal(tester);

        TestTermsUtil.verifyAllTermsTextsDisplay();
        TestRenderVerifier.expectRenders<TermsAgreementItem>(count: 4);
        TestRenderVerifier.expectRenders<TermsAgreeButton>();
      });
    });
  });
}
