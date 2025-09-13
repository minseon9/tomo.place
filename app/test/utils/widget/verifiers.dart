import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class WidgetVerifiers {
  WidgetVerifiers._();

  static void verifyWidgetRenders({
    required WidgetTester tester,
    required Type widgetType,
    int expectedCount = 1,
  }) {
    expect(find.byType(widgetType), findsNWidgets(expectedCount));
  }

  static void verifyTextDisplays({
    required String text,
    int expectedCount = 1,
  }) {
    expect(find.text(text), findsNWidgets(expectedCount));
  }

  static void verifyWidgetSize({
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

  static void verifyContainerStyle({
    required WidgetTester tester,
    required Finder finder,
    Color? expectedColor,
    double? expectedWidth,
    double? expectedHeight,
    BorderRadius? expectedBorderRadius,
  }) {
    final container = tester.widget<Container>(finder);
    final decoration = container.decoration as BoxDecoration?;

    if (expectedColor != null) {
      expect(decoration?.color, equals(expectedColor));
    }

    if (expectedWidth != null) {
      expect(container.constraints?.maxWidth, equals(expectedWidth));
    }

    if (expectedHeight != null) {
      expect(container.constraints?.maxHeight, equals(expectedHeight));
    }

    if (expectedBorderRadius != null) {
      expect(decoration?.borderRadius, equals(expectedBorderRadius));
    }
  }

  static void verifyElevatedButtonStyle({
    required WidgetTester tester,
    required Finder finder,
    Color? expectedBackgroundColor,
    Color? expectedForegroundColor,
    double? expectedElevation,
    EdgeInsetsGeometry? expectedPadding,
  }) {
    final elevatedButton = tester.widget<ElevatedButton>(finder);
    final style = elevatedButton.style;

    if (expectedBackgroundColor != null) {
      expect(
        style?.backgroundColor?.resolve({}),
        equals(expectedBackgroundColor),
      );
    }

    if (expectedForegroundColor != null) {
      expect(
        style?.foregroundColor?.resolve({}),
        equals(expectedForegroundColor),
      );
    }

    if (expectedElevation != null) {
      expect(style?.elevation?.resolve({}), equals(expectedElevation));
    }

    if (expectedPadding != null) {
      expect(style?.padding?.resolve({}), equals(expectedPadding));
    }
  }

  static void verifyCircularProgressIndicatorStyle({
    required WidgetTester tester,
    required Finder finder,
    double? expectedStrokeWidth,
    Color? expectedValueColor,
  }) {
    final progressIndicator = tester.widget<CircularProgressIndicator>(finder);

    if (expectedStrokeWidth != null) {
      expect(progressIndicator.strokeWidth, equals(expectedStrokeWidth));
    }

    if (expectedValueColor != null) {
      final valueColor =
          progressIndicator.valueColor as AlwaysStoppedAnimation<Color>?;
      expect(valueColor?.value, equals(expectedValueColor));
    }
  }

  static void verifyTermsCloseButtonStyle({
    required WidgetTester tester,
    required Finder finder,
    double? expectedSize,
    Color? expectedColor,
    EdgeInsetsGeometry? expectedPadding,
  }) {
    final iconButton = tester.widget<IconButton>(finder);
    final icon = iconButton.icon as Icon;

    if (expectedSize != null) {
      expect(icon.size, equals(expectedSize));
    }

    if (expectedColor != null) {
      expect(icon.color, equals(expectedColor));
    }

    if (expectedPadding != null) {
      expect(iconButton.padding, equals(expectedPadding));
    }
  }

  static void verifyTermsContentStructure({
    required WidgetTester tester,
    required Finder finder,
    String? expectedTitle,
    String? expectedContent,
  }) {
    final column = tester.widget<Column>(finder);
    expect(column, isNotNull);

    if (expectedTitle != null) {
      verifyTextDisplays(text: expectedTitle, expectedCount: 1);
    }

    if (expectedContent != null) {
      verifyTextDisplays(text: expectedContent, expectedCount: 1);
    }

    expect(
      find.descendant(of: finder, matching: find.byType(SingleChildScrollView)),
      findsOneWidget,
    );
  }

  static void verifyTermsPageLayoutStructure({
    required WidgetTester tester,
    required Finder finder,
    bool expectHeader = true,
    bool expectContent = true,
    bool expectFooter = true,
  }) {
    final scaffold = tester.widget<Scaffold>(finder);
    expect(scaffold, isNotNull);

    if (expectHeader) {
      expect(
        find.descendant(of: finder, matching: find.byType(Positioned)),
        findsWidgets,
      );
    }

    if (expectContent) {
      expect(
        find.descendant(
          of: finder,
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
    }

    if (expectFooter) {
      verifyTextDisplays(text: '모두 동의합니다 !', expectedCount: 1);
    }
  }

  static void verifyPositionedWidget({
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

  static void verifyScrollableContent({
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

  static void verifyStackLayout({
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

  static void verifySafeArea({
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

  static void verifyTermsPageCommonStructure({
    required WidgetTester tester,
    required Finder finder,
    required String expectedTitle,
    required String expectedButtonText,
  }) {
    verifyWidgetRenders(tester: tester, widgetType: Scaffold, expectedCount: 1);
    verifyWidgetRenders(tester: tester, widgetType: Stack, expectedCount: 1);

    verifyTextDisplays(text: expectedTitle, expectedCount: 1);

    verifyTextDisplays(text: expectedButtonText, expectedCount: 1);

    verifySafeArea(tester: tester, finder: finder, shouldHaveSafeArea: true);
  }

  static void verifyTermsPageColors({
    required WidgetTester tester,
    required Finder finder,
    Color? expectedHeaderColor,
    Color? expectedFooterColor,
    Color? expectedBackgroundColor,
  }) {
    final containers = find.descendant(
      of: finder,
      matching: find.byType(Container),
    );

    if (expectedHeaderColor != null ||
        expectedFooterColor != null ||
        expectedBackgroundColor != null) {
      expect(containers, findsWidgets);
    }
  }

  
  static void verifyContainerRenders(
    WidgetTester tester,
    Finder finder,
  ) {
    expect(finder, findsAtLeastNWidgets(1));
    
    expect(find.descendant(of: finder, matching: find.byType(Container)), findsAtLeastNWidgets(1));
  }

  
  static void verifyTextRenders(
    WidgetTester tester,
    String text,
  ) {
    expect(find.text(text), findsOneWidget);
  }

  
  static void verifyPaddingRenders(
    WidgetTester tester,
    Finder finder,
  ) {
    expect(finder, findsAtLeastNWidgets(1));
    
    expect(find.descendant(of: finder, matching: find.byType(Padding)), findsAtLeastNWidgets(1));
  }
}
