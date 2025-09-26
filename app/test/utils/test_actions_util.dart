import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestActionsUtil {
  static Future<void> tapTextAndSettle(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  static Future<void> tapFinderAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> enterTextAndSettle(WidgetTester tester, Finder finder, String text) async {
    await tester.tap(finder);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  static Future<void> tapIconAndSettle(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await tester.pumpAndSettle();
  }

  
  static Future<void> tapByKeyAndSettle(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  
  static Future<void> scrollAndSettle(WidgetTester tester, Finder finder, Offset offset) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle();
  }

  
  static Future<void> longPressAndSettle(WidgetTester tester, Finder finder) async {
    await tester.longPress(finder);
    await tester.pumpAndSettle();
  }

  
  static Future<void> hideKeyboard(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
  }

  
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
