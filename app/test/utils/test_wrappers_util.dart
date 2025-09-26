import 'package:flutter/material.dart';


class TestWrappersUtil {
  TestWrappersUtil._();

  static Widget material(
    Widget child, {
    Size? screenSize,
    List<NavigatorObserver>? navigatorObservers,
  }) {
    return MaterialApp(
      home: Scaffold(body: child),
      navigatorObservers: navigatorObservers ?? const <NavigatorObserver>[],
      builder: (context, childWidget) {
        if (screenSize == null) {
          return childWidget!;
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(size: screenSize),
          child: childWidget!,
        );
      },
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
    return material(
      child,
      screenSize: screenSize ?? const Size(390.0, 844.0),
    );
  }

  static Widget createTestApp({
    required Widget child,
    List<NavigatorObserver>? navigatorObservers,
    Size? screenSize,
  }) {
    return material(
      child,
      navigatorObservers: navigatorObservers,
      screenSize: screenSize,
    );
  }

  static Widget createTestAppWithRouting({
    required Widget child,
    String initialRoute = '/',
    Map<String, WidgetBuilder>? routes,
    Size? screenSize,
    List<NavigatorObserver>? navigatorObservers,
  }) {
    final routeMap = <String, WidgetBuilder>{
      '/': (_) => child,
      if (routes != null) ...routes,
    };

    return MaterialApp(
      initialRoute: initialRoute,
      routes: routeMap,
      navigatorObservers: navigatorObservers ?? const <NavigatorObserver>[],
      builder: (context, childWidget) {
        if (screenSize == null) {
          return childWidget!;
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(size: screenSize),
          child: childWidget!,
        );
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
