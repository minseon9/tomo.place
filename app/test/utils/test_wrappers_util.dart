import 'package:flutter/material.dart';


class TestWrappersUtil {
  TestWrappersUtil._();

  static Widget material(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

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

  static Widget createTestApp({
    required Widget child,
    List<NavigatorObserver>? navigatorObservers,
  }) {
    return MaterialApp(
      home: Scaffold(body: child),
      navigatorObservers: navigatorObservers ?? [],
    );
  }

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
