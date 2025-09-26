import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/location_terms_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/privacy_policy_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/pages/terms_of_service_page.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_agreement_modal.dart';
import 'package:tomo_place/shared/application/routes/routes.dart';

class MockVoidCallback extends Mock {
  void call();
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class TestNavigatorObserver extends NavigatorObserver {
  final List<String> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route.settings.name ?? '');
    super.didPush(route, route);
  }
}

class FakeRoute extends Fake implements Route<dynamic> {}

class TestTermsUtil {
  TestTermsUtil._();

  static MockVoidCallback createVoidCallback() => MockVoidCallback();
  static MockNavigatorObserver createNavigatorObserver() => MockNavigatorObserver();

  static Widget buildModal({
    required void Function(TermsAgreementResult) onResult,
    Size screenSize = const Size(390.0, 844.0),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: TermsAgreementModal(onResult: onResult),
        ),
      ),
    );
  }

  static Widget buildModalWithRoutes({
    required void Function(TermsAgreementResult) onResult,
    Size screenSize = const Size(390.0, 844.0),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: TermsAgreementModal(onResult: onResult),
        ),
      ),
      routes: getTermsRoutes(),
    );
  }

  static Map<String, WidgetBuilder> getTermsRoutes() {
    return {
      Routes.termsOfService: (context) => const TermsOfServicePage(),
      Routes.privacyPolicy: (context) => const PrivacyPolicyPage(),
      Routes.locationTerms: (context) => const LocationTermsPage(),
    };
  }

  static const String termsTitle = '이용 약관 동의';
  static const String privacyTitle = '개인정보 보호 방침 동의';
  static const String locationTitle = '위치정보 수집·이용 및 제3자 제공 동의';
  static const String ageTitle = '만 14세 이상입니다';
  static const String agreeAllButton = '모두 동의합니다 !';

  static Finder findTermsTitle() => find.text(termsTitle);
  static Finder findPrivacyTitle() => find.text(privacyTitle);
  static Finder findLocationTitle() => find.text(locationTitle);
  static Finder findAgeTitle() => find.text(ageTitle);
  static Finder findAgreeAllButton() => find.text(agreeAllButton);

  static void verifyAllTermsTextsDisplay() {
    const termsTexts = [
      termsTitle,
      privacyTitle,
      locationTitle,
      ageTitle,
    ];

    for (final text in termsTexts) {
      expect(find.text(text), findsOneWidget);
    }
  }

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
    final agreeButton = find.text(agreeAllButton);
    final agreeButtonRect = tester.getRect(agreeButton);

    final targetX = agreeButtonRect.center.dx / 2;
    final targetY = agreeButtonRect.center.dy;

    return Offset(targetX, targetY);
  }
}
