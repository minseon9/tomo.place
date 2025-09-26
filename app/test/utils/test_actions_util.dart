import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트 액션 유틸리티 - 의미있는 상호작용과 검증을 포함한 액션 제공
class TestActionsUtil {
  TestActionsUtil._();

  /// 텍스트를 탭하고 settle까지 수행
  static Future<void> tapTextAndSettle(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// Finder를 탭하고 settle까지 수행
  static Future<void> tapFinderAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// 텍스트 입력하고 settle까지 수행
  static Future<void> enterTextAndSettle(WidgetTester tester, Finder finder, String text) async {
    await tester.tap(finder);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// 아이콘을 탭하고 settle까지 수행
  static Future<void> tapIconAndSettle(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await tester.pumpAndSettle();
  }

  /// 키로 위젯을 찾아서 탭하고 settle까지 수행
  static Future<void> tapByKeyAndSettle(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  /// 스크롤하고 settle까지 수행
  static Future<void> scrollAndSettle(WidgetTester tester, Finder finder, Offset offset) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle();
  }

  /// 길게 누르고 settle까지 수행
  static Future<void> longPressAndSettle(WidgetTester tester, Finder finder) async {
    await tester.longPress(finder);
    await tester.pumpAndSettle();
  }

  /// 키보드 숨기기
  static Future<void> hideKeyboard(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
  }

  /// 버튼 탭이 콜백을 호출하는지 검증하는 헬퍼
  static Future<void> expectButtonTapInvokes({
    required WidgetTester tester,
    required Finder buttonFinder,
    required VoidCallback onPressed,
    bool shouldBeEnabled = true,
  }) async {
    bool callbackCalled = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: shouldBeEnabled ? () {
              callbackCalled = true;
              onPressed();
            } : null,
            child: const Text('Test Button'),
          ),
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
