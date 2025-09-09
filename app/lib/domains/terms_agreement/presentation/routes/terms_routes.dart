import 'package:flutter/material.dart';

import '../../../../shared/application/routes/routes.dart';
import '../pages/location_terms_page.dart';
import '../pages/privacy_policy_page.dart';
import '../pages/terms_of_service_page.dart';

class TermsRoutes {
  TermsRoutes._();

  static Map<String, WidgetBuilder> get builders => {
    Routes.termsOfService: (context) => const TermsOfServicePage(),
    Routes.privacyPolicy: (context) => const PrivacyPolicyPage(),
    Routes.locationTerms: (context) => const LocationTermsPage(),
  };
}
