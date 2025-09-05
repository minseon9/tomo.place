import 'package:flutter/material.dart';

import '../../domains/auth/presentation/routes/auth_routes.dart';
import '../pages/splash_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Map<String, WidgetBuilder> builders = {
      ...AuthRoutes.builders,

      '/splash': (context) => const SplashPage(),

      // 홈 화면 (추후 별도 도메인으로 분리 예정)
      '/home': (context) =>
          const Scaffold(body: Center(child: Text('홈 화면 (추후 구현)'))),
    };

    final builder = builders[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }

    // 404 페이지
    return MaterialPageRoute(
      builder: (_) =>
          const Scaffold(body: Center(child: Text('페이지를 찾을 수 없습니다'))),
      settings: settings,
    );
  }
}
