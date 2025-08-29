import 'package:flutter/material.dart';
import '../pages/signup_page.dart';
import '../../../../shared/infrastructure/external_services/google_auth_test_page.dart';

/// Auth 도메인 라우트 정의
class AuthRoutes {
  static const String signup = '/signup';
  static const String googleAuthTest = '/google-auth-test';
  
  static Map<String, WidgetBuilder> get builders => {
    signup: (context) => const SignupPage(),
    googleAuthTest: (context) => const GoogleAuthTestPage(),
  };
}
