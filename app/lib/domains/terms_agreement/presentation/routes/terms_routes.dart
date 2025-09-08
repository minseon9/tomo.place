import 'package:flutter/material.dart';
import '../../../../shared/application/routes/routes.dart';
import '../pages/terms_of_service_page.dart';
import '../pages/privacy_policy_page.dart';
import '../pages/location_terms_page.dart';

/// Terms Agreement 도메인의 라우팅 설정
/// 
/// 중앙 관리되는 Routes 클래스를 사용하여 라우트를 정의합니다.
class TermsRoutes {
  TermsRoutes._();
  
  static Map<String, WidgetBuilder> get builders => {
    Routes.termsOfService: (context) => const TermsOfServicePage(),
    Routes.privacyPolicy: (context) => const PrivacyPolicyPage(),
    Routes.locationTerms: (context) => const LocationTermsPage(),
  };
}
