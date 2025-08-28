import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/email_login_page.dart';

/// Auth 도메인 라우트 정의
class AuthRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String emailLogin = '/email-login';
  
  static Map<String, WidgetBuilder> get builders => {
    login: (context) => const LoginPage(),
    signup: (context) => const SignupPage(),
    emailLogin: (context) => const EmailLoginPage(),
  };
}
