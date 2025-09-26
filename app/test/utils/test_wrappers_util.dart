import 'package:flutter/material.dart';

/// 테스트 래퍼 유틸리티 - 위젯을 다양한 앱 구조로 감싸는 헬퍼
class TestWrappersUtil {
  TestWrappersUtil._();

  /// 위젯을 MaterialApp으로 감싸기
  static Widget material(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// 위젯을 MaterialApp과 Navigator로 감싸기
  static Widget withNavigator(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => child,
          ),
        ),
      ),
    );
  }

  /// 위젯을 MaterialApp으로 감싸기 (화면 크기 설정 포함)
  static Widget withScreenSize(Widget child, {Size? screenSize}) {
    return MaterialApp(
      home: Scaffold(body: child),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: screenSize ?? const Size(390.0, 844.0), // iPhone 13 기준 모바일 평균 크기
          ),
          child: child!,
        );
      },
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
