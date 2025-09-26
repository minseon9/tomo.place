import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/location_terms_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/privacy_policy_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/terms_of_service_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_agreement_modal.dart';
import 'package:tomo_place/shared/application/routes/routes.dart';

import '../test_wrappers_util.dart';
import '../verifiers/test_render_verifier.dart';

class MockVoidCallback extends Mock {
  void call();
}

class MockValueChangedBool extends Mock {
  void call(bool? value);
}

class MockTermsModalCallbacks extends Mock {
  void onResult(TermsAgreementResult result);
}

typedef TermsMocks = ({
  MockVoidCallback onPressed,
  MockValueChangedBool onChanged,
  MockTermsModalCallbacks modalCallbacks,
});

class TestTermsUtil {
  TestTermsUtil._();

  static TermsMocks createMocks() => (
        onPressed: MockVoidCallback(),
        onChanged: MockValueChangedBool(),
        modalCallbacks: MockTermsModalCallbacks(),
      );

  static const termsTitle = '이용 약관 동의';
  static const privacyTitle = '개인정보 보호 방침 동의';
  static const locationTitle = '위치정보 수집·이용 및 제3자 제공 동의';
  static const ageTitle = '만 14세 이상입니다';
  static const agreeAllButton = '모두 동의합니다 !';

  static Map<String, String> termsContent() => {
        '제1조 (목적)': '본 약관은 tomo place가 제공하는 서비스의 이용 조건을 규정합니다.',
        '제2조 (회원의 의무)': '회원은 관계 법령 및 본 약관을 준수해야 합니다.',
      };

  static Map<String, String> privacyContent() => {
        '수집·이용 목적': '회원 식별 및 맞춤형 서비스 제공',
        '보유 및 이용 기간': '회원 탈퇴 시까지 또는 관계 법령에 따른 기간',
      };

  static Map<String, String> locationContent() => {
        '위치정보 제공 동의': '서비스 제공을 위해 단말기의 위치정보를 수집·이용할 수 있습니다.',
        '제3자 제공': '서비스 개선을 위해 위치정보를 제3자에게 제공할 수 있습니다.',
      };

  static Map<String, String> generateLargeContent({int count = 10}) {
    final entries = <String, String>{};
    for (var i = 1; i <= count; i++) {
      entries['제$i조 (목적)'] =
          '본 약관은 tomo place가 제공하는 서비스의 이용 조건 및 절차를 규정함을 목적으로 합니다. ' * 3;
    }
    return entries;
  }

  static Widget buildModal({
    required void Function(TermsAgreementResult result) onResult,
  }) {
    return TestWrappersUtil.material(
      createModal(onResult: onResult),
    );
  }

  static Widget buildModalWithRoutes({
    required void Function(TermsAgreementResult result) onResult,
  }) {
    final modal = createModal(onResult: onResult);
    return TestWrappersUtil.createTestAppWithRouting(
      child: modal,
      routes: {
        ...routes(),
      },
    );
  }

  static TermsAgreementModal createModal({
    required void Function(TermsAgreementResult result) onResult,
  }) {
    return TermsAgreementModal(onResult: onResult);
  }

  static Map<String, WidgetBuilder> routes() => {
        Routes.termsOfService: (_) => const TermsOfServicePage(),
        Routes.privacyPolicy: (_) => const PrivacyPolicyPage(),
        Routes.locationTerms: (_) => const LocationTermsPage(),
      };

  static void verifyTermsRoutesDefined() {
    expect(Routes.termsOfService, equals('/terms/terms-of-service'));
    expect(Routes.privacyPolicy, equals('/terms/privacy-policy'));
    expect(Routes.locationTerms, equals('/terms/location-terms'));
  }

  static void verifyTermsRoutesPrefix() {
    const termsRoutes = [
      Routes.termsOfService,
      Routes.privacyPolicy,
      Routes.locationTerms,
    ];

    for (final route in termsRoutes) {
      expect(route, startsWith('/terms/'));
    }
  }

  static void verifyTermsRoutesFormat() {
    const termsRoutes = [
      Routes.termsOfService,
      Routes.privacyPolicy,
      Routes.locationTerms,
    ];

    for (final route in termsRoutes) {
      expect(route, startsWith('/'));
      expect(route, matches(r'^/[a-zA-Z0-9\-/]*$'));
    }
  }

  static void verifyTermsRoutesUnique() {
    const termsRoutes = [
      Routes.termsOfService,
      Routes.privacyPolicy,
      Routes.locationTerms,
    ];

    final uniqueRoutes = termsRoutes.toSet();
    expect(uniqueRoutes.length, equals(termsRoutes.length));
  }

  static Finder findAgreeAllButton() => find.text(agreeAllButton);

  static void verifyAllTermsTextsDisplay() {
    TestRenderVerifier.expectText(termsTitle);
    TestRenderVerifier.expectText(privacyTitle);
    TestRenderVerifier.expectText(locationTitle);
    TestRenderVerifier.expectText(ageTitle);
  }

  static Future<void> measureRenderingTime(
    WidgetTester tester,
    Widget widget, {
    int maxMilliseconds = 1000,
  }) async {
    final stopwatch = Stopwatch()..start();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(maxMilliseconds));
  }

  static Offset calculateExternalTouchPoint() {
    return const Offset(10, 10);
  }

  static Offset calculateInternalTouchPoint(WidgetTester tester) {
    final agreeButtonRect = tester.getRect(findAgreeAllButton());
    final targetX = agreeButtonRect.center.dx / 2;
    final targetY = agreeButtonRect.center.dy;
    return Offset(targetX, targetY);
  }
}

