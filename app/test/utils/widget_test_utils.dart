import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 위젯 테스트를 위한 유틸리티
class WidgetTestUtils {
  WidgetTestUtils._();

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
}

/// 위젯 테스트를 위한 액션들
class WidgetTestActions {
  WidgetTestActions._();

  /// 텍스트 입력
  static Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
    await tester.tap(finder);
    await tester.enterText(finder, text);
  }
  
  /// 탭 동작
  static Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
  }
  
  /// 스크롤 동작
  static Future<void> scroll(WidgetTester tester, Finder finder, Offset offset) async {
    await tester.drag(finder, offset);
  }
  
  /// 길게 누르기
  static Future<void> longPress(WidgetTester tester, Finder finder) async {
    await tester.longPress(finder);
  }
  
  /// 키보드 숨기기
  static Future<void> hideKeyboard(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
  }

  /// 버튼 탭하기
  static Future<void> tapButton(WidgetTester tester, String buttonText) async {
    final button = find.text(buttonText);
    await tester.tap(button);
  }

  /// 아이콘 탭하기
  static Future<void> tapIcon(WidgetTester tester, IconData icon) async {
    final iconFinder = find.byIcon(icon);
    await tester.tap(iconFinder);
  }

  /// 키로 위젯 찾아서 탭하기
  static Future<void> tapByKey(WidgetTester tester, Key key) async {
    final finder = find.byKey(key);
    await tester.tap(finder);
  }
}

/// 위젯 테스트를 위한 Finder들
class WidgetTestFinders {
  WidgetTestFinders._();

  /// 텍스트로 위젯 찾기 (정확한 매칭)
  static Finder byText(String text) => find.text(text);
  
  /// 텍스트로 위젯 찾기 (부분 매칭)
  static Finder byTextContaining(String text) => find.textContaining(text);
  
  /// 아이콘으로 위젯 찾기
  static Finder byIcon(IconData icon) => find.byIcon(icon);
  
  /// 키로 위젯 찾기
  static Finder byKey(Key key) => find.byKey(key);
  
  /// 테스트 키로 위젯 찾기
  static Finder byTestKey(String key) => find.byKey(Key(key));
  
  /// 자식 위젯 찾기
  static Finder byChild(Finder parent, Finder child) => find.descendant(
    of: parent,
    matching: child,
  );

  /// 위젯 타입으로 찾기
  static Finder byType<T extends Widget>() => find.byType(T);
}
