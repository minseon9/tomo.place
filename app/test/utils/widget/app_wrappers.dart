import 'package:flutter/material.dart';

/// 위젯 테스트를 위한 앱 래퍼 유틸리티
class AppWrappers {
  AppWrappers._();

  /// 위젯을 MaterialApp으로 감싸기
  static Widget wrapWithMaterialApp(Widget widget) {
    return MaterialApp(
      home: Scaffold(body: widget),
    );
  }

  /// 위젯을 MaterialApp과 Navigator로 감싸기
  static Widget wrapWithMaterialAppAndNavigator(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => widget,
          ),
        ),
      ),
    );
  }

  /// 테스트용 앱 생성 (AuthStatusCard용)
  static Widget createTestApp({
    required Widget child,
    List<NavigatorObserver>? navigatorObservers,
  }) {
    return MaterialApp(
      home: Scaffold(body: child),
      navigatorObservers: navigatorObservers ?? [],
    );
  }

  /// 테스트용 앱 생성 (라우팅 포함)
  static Widget createTestAppWithRouting({
    required Widget child,
    String initialRoute = '/',
    Map<String, WidgetBuilder>? routes,
  }) {
    return MaterialApp(
      initialRoute: initialRoute,
      routes: routes ?? {
        '/': (context) => child,
      },
    );
  }

  /// Column으로 위젯을 래핑하는 헬퍼 (레이아웃 테스트용)
  static Widget wrapWithColumn({
    required Widget child,
    List<Widget>? additionalChildren,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            if (additionalChildren != null) ...additionalChildren,
            child,
          ],
        ),
      ),
    );
  }

  /// Row로 위젯을 래핑하는 헬퍼 (레이아웃 테스트용)
  static Widget wrapWithRow({
    required Widget child,
    List<Widget>? additionalChildren,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            if (additionalChildren != null) ...additionalChildren,
            child,
          ],
        ),
      ),
    );
  }
}
