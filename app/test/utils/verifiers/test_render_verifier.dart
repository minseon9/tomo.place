import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


class TestRenderVerifier {
  TestRenderVerifier._();

  static void expectRenders<T>({int count = 1}) {
    expect(find.byType(T), findsNWidgets(count));
  }

  static void expectText(String text, {int count = 1}) {
    expect(find.text(text), findsNWidgets(count));
  }

  static Finder findSingle<T>() {
    final finder = find.byType(T);
    expect(finder, findsOneWidget);
    return finder;
  }

  // moved to style verifier

  static void expectSnackBar({String? message}) {
    expect(find.byType(SnackBar), findsWidgets);
    if (message != null) {
      expect(find.text(message), findsWidgets);
    }
  }

  static void expectWidgetSize({
    required WidgetTester tester,
    required Finder finder,
    double? expectedWidth,
    double? expectedHeight,
  }) {
    final renderBox = tester.renderObject<RenderBox>(finder);

    if (expectedWidth != null) {
      expect(renderBox.size.width, equals(expectedWidth));
    }

    if (expectedHeight != null) {
      expect(renderBox.size.height, equals(expectedHeight));
    }
  }

  static void expectScrollableContent({
    required WidgetTester tester,
    required Finder finder,
    bool shouldBeScrollable = true,
  }) {
    if (shouldBeScrollable) {
      expect(
        find.descendant(
          of: finder,
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
    } else {
      expect(
        find.descendant(
          of: finder,
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
    }
  }

  static void expectSafeArea({
    required WidgetTester tester,
    required Finder finder,
    bool shouldHaveSafeArea = true,
  }) {
    if (shouldHaveSafeArea) {
      expect(
        find.descendant(of: finder, matching: find.byType(SafeArea)),
        findsWidgets,
      );
    } else {
      expect(
        find.descendant(of: finder, matching: find.byType(SafeArea)),
        findsNothing,
      );
    }
  }

  static void expectStackLayout({
    required WidgetTester tester,
    required Finder finder,
    required int expectedChildrenCount,
  }) {
    expect(finder, findsAtLeastNWidgets(1));
    final stacks = tester.widgetList<Stack>(finder);
    expect(stacks.isNotEmpty, isTrue);
    final mainStack = stacks.first;
    expect(mainStack.children.length, equals(expectedChildrenCount));
  }

  static void expectPositionedWidget({
    required WidgetTester tester,
    required Finder finder,
    double? expectedTop,
    double? expectedLeft,
    double? expectedRight,
    double? expectedBottom,
    double? expectedHeight,
    double? expectedWidth,
  }) {
    final positioned = tester.widget<Positioned>(finder);

    if (expectedTop != null) {
      expect(positioned.top, equals(expectedTop));
    }

    if (expectedLeft != null) {
      expect(positioned.left, equals(expectedLeft));
    }

    if (expectedRight != null) {
      expect(positioned.right, equals(expectedRight));
    }

    if (expectedBottom != null) {
      expect(positioned.bottom, equals(expectedBottom));
    }

    if (expectedHeight != null) {
      expect(positioned.height, equals(expectedHeight));
    }

    if (expectedWidth != null) {
      expect(positioned.width, equals(expectedWidth));
    }
  }
}
