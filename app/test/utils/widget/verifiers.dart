import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 위젯 테스트를 위한 검증 유틸리티
class WidgetVerifiers {
  WidgetVerifiers._();

  /// 위젯이 올바르게 렌더링되는지 검증하는 헬퍼
  static void verifyWidgetRenders({
    required WidgetTester tester,
    required Type widgetType,
    int expectedCount = 1,
  }) {
    expect(find.byType(widgetType), findsNWidgets(expectedCount));
  }

  /// 텍스트가 올바르게 표시되는지 검증하는 헬퍼
  static void verifyTextDisplays({
    required String text,
    int expectedCount = 1,
  }) {
    expect(find.text(text), findsNWidgets(expectedCount));
  }

  /// 위젯의 크기를 검증하는 헬퍼
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

  /// Container의 스타일을 검증하는 헬퍼
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

  /// ElevatedButton의 스타일을 검증하는 헬퍼
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
      expect(style?.backgroundColor?.resolve({}), equals(expectedBackgroundColor));
    }

    if (expectedForegroundColor != null) {
      expect(style?.foregroundColor?.resolve({}), equals(expectedForegroundColor));
    }

    if (expectedElevation != null) {
      expect(style?.elevation?.resolve({}), equals(expectedElevation));
    }

    if (expectedPadding != null) {
      expect(style?.padding?.resolve({}), equals(expectedPadding));
    }
  }

  /// CircularProgressIndicator의 스타일을 검증하는 헬퍼
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
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>?;
      expect(valueColor?.value, equals(expectedValueColor));
    }
  }
}
