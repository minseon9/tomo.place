import 'package:flutter/material.dart';

import '../../app/services/navigation_service.dart';

class GracefulLogoutHandler {
  static void handle({String? customMessage}) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(customMessage ?? '로그인 세션이 만료되었습니다.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  static void handleAuthError(String errorMessage) {
    handle(customMessage: '로그인 중 오류가 발생했습니다: $errorMessage');
  }
}
