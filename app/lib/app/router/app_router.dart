import 'package:flutter/material.dart';

import '../../domains/auth/presentation/pages/login_page.dart';
import '../../domains/auth/presentation/pages/email_login_page.dart';
import '../../domains/auth/presentation/pages/signup_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String emailLogin = '/email-login';
  static const String signup = '/signup';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case emailLogin:
        return MaterialPageRoute(
          builder: (_) => const EmailLoginPage(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('홈 화면 (추후 구현)'),
            ),
          ),
          settings: settings,
        );
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignupPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('페이지를 찾을 수 없습니다'),
            ),
          ),
        );
    }
  }
}
