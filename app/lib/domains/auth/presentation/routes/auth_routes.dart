import 'package:flutter/material.dart';
import '../pages/signup_page.dart';

/// Auth 도메인 라우트 정의
class AuthRoutes {
  static const String signup = '/signup';
  
  static Map<String, WidgetBuilder> get builders => {
    signup: (context) => const SignupPage(),
  };
}
