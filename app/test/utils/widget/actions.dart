import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'app_wrappers.dart';

/// 위젯 테스트를 위한 액션 유틸리티
class WidgetActions {
  WidgetActions._();

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

  /// 버튼 클릭 테스트 헬퍼
  static Future<void> testButtonClick({
    required WidgetTester tester,
    required Finder buttonFinder,
    required VoidCallback onPressed,
    bool shouldBeEnabled = true,
  }) async {
    bool callbackCalled = false;
    
    await tester.pumpWidget(
      AppWrappers.wrapWithMaterialApp(
        ElevatedButton(
          onPressed: shouldBeEnabled ? () {
            callbackCalled = true;
            onPressed();
          } : null,
          child: const Text('Test Button'),
        ),
      ),
    );

    await tester.tap(buttonFinder);
    await tester.pump();

    if (shouldBeEnabled) {
      expect(callbackCalled, isTrue);
    } else {
      expect(callbackCalled, isFalse);
    }
  }
}
