import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domains/auth/presentation/routes/auth_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/signup',
    routes: <RouteBase>[
      // Auth 도메인 라우트들
      ...authRoutes,
      
      // 홈 화면 (추후 별도 도메인으로 분리 예정)
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
