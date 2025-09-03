import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToSignup() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/signup',
      (route) => false,
    );
  }

  static void navigateToHome() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  static void showTokenExpiredSnackBar() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 세션이 만료되었습니다'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
