import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domains/auth/presentation/pages/login_page.dart';
import '../../domains/auth/presentation/pages/email_login_page.dart';
import '../../domains/auth/presentation/pages/signup_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/email-login',
        builder: (context, state) => const EmailLoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('홈 화면 (추후 구현)'),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('페이지를 찾을 수 없습니다'),
      ),
    ),
  );
}
