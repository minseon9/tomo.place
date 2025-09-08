import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domains/auth/presentation/routes/auth_routes.dart';
import '../../domains/terms_agreement/presentation/routes/terms_routes.dart';
import '../pages/splash_page.dart';

Route<dynamic> _generateRoute(RouteSettings settings) {
  final Map<String, WidgetBuilder> builders = {
    ...AuthRoutes.builders,
    ...TermsRoutes.builders,

    '/splash': (context) => const SplashPage(),

    '/home': (context) =>
        const Scaffold(body: Center(child: Text('홈 화면 (추후 구현)'))),
  };

  final builder = builders[settings.name];
  if (builder != null) {
    return MaterialPageRoute(builder: builder, settings: settings);
  }

  return MaterialPageRoute(
    builder: (_) =>
        const Scaffold(body: Center(child: Text('페이지를 찾을 수 없습니다'))),
    settings: settings,
  );
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return _generateRoute(settings);
  }
}

final routerProvider = Provider<Route<dynamic> Function(RouteSettings)>(
      (ref) => (RouteSettings settings) => _generateRoute(settings),
);
