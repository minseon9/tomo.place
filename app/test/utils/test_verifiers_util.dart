import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트 검증 유틸리티 - 핵심적인 검증 기능만 제공
class TestVerifiersUtil {
  TestVerifiersUtil._();

  /// 위젯이 렌더링되는지 검증
  static void expectRenders<T>({int count = 1}) {
    expect(find.byType(T), findsNWidgets(count));
  }

  /// 텍스트가 표시되는지 검증
  static void expectText(String text, {int count = 1}) {
    expect(find.text(text), findsNWidgets(count));
  }

  /// 스낵바가 표시되는지 검증
  static void expectSnackBar({String? message}) {
    expect(find.byType(SnackBar), findsWidgets);
    if (message != null) {
      expect(find.text(message), findsWidgets);
    }
  }

  /// 위젯 크기 검증
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

  /// 스크롤 가능한 콘텐츠 검증
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

  /// SafeArea 검증
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

  /// Stack 레이아웃 검증
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

  /// Positioned 위젯 검증
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
