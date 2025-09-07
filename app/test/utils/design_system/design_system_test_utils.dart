import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../widget/app_wrappers.dart';
import '../widget/verifiers.dart';

/// Design System 위젯 테스트를 위한 전용 유틸리티
class DesignSystemTestUtils {
  DesignSystemTestUtils._();

  /// MaterialApp으로 위젯을 래핑하는 헬퍼
  static Widget wrapWithMaterialApp({
    required Widget child,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Column으로 위젯을 래핑하는 헬퍼 (레이아웃 테스트용)
  static Widget wrapWithColumn({
    required Widget child,
    List<Widget>? additionalChildren,
  }) {
    return AppWrappers.wrapWithColumn(
      child: child,
      additionalChildren: additionalChildren,
    );
  }

  /// Row로 위젯을 래핑하는 헬퍼 (레이아웃 테스트용)
  static Widget wrapWithRow({
    required Widget child,
    List<Widget>? additionalChildren,
  }) {
    return AppWrappers.wrapWithRow(
      child: child,
      additionalChildren: additionalChildren,
    );
  }

  // ===== 검증 메서드들 (WidgetVerifiers로 위임) =====

  /// Container의 스타일을 검증하는 헬퍼
  static void verifyContainerStyle({
    required WidgetTester tester,
    required Finder finder,
    Color? expectedColor,
    double? expectedWidth,
    double? expectedHeight,
    BorderRadius? expectedBorderRadius,
  }) {
    WidgetVerifiers.verifyContainerStyle(
      tester: tester,
      finder: finder,
      expectedColor: expectedColor,
      expectedWidth: expectedWidth,
      expectedHeight: expectedHeight,
      expectedBorderRadius: expectedBorderRadius,
    );
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
    WidgetVerifiers.verifyElevatedButtonStyle(
      tester: tester,
      finder: finder,
      expectedBackgroundColor: expectedBackgroundColor,
      expectedForegroundColor: expectedForegroundColor,
      expectedElevation: expectedElevation,
      expectedPadding: expectedPadding,
    );
  }

  /// CircularProgressIndicator의 스타일을 검증하는 헬퍼
  static void verifyCircularProgressIndicatorStyle({
    required WidgetTester tester,
    required Finder finder,
    double? expectedStrokeWidth,
    Color? expectedValueColor,
  }) {
    WidgetVerifiers.verifyCircularProgressIndicatorStyle(
      tester: tester,
      finder: finder,
      expectedStrokeWidth: expectedStrokeWidth,
      expectedValueColor: expectedValueColor,
    );
  }

  /// 위젯이 올바르게 렌더링되는지 검증하는 헬퍼
  static void verifyWidgetRenders({
    required WidgetTester tester,
    required Type widgetType,
    int expectedCount = 1,
  }) {
    WidgetVerifiers.verifyWidgetRenders(
      tester: tester,
      widgetType: widgetType,
      expectedCount: expectedCount,
    );
  }

  /// 텍스트가 올바르게 표시되는지 검증하는 헬퍼
  static void verifyTextDisplays({
    required String text,
    int expectedCount = 1,
  }) {
    WidgetVerifiers.verifyTextDisplays(
      text: text,
      expectedCount: expectedCount,
    );
  }

  /// 위젯의 크기를 검증하는 헬퍼
  static void verifyWidgetSize({
    required WidgetTester tester,
    required Finder finder,
    double? expectedWidth,
    double? expectedHeight,
  }) {
    WidgetVerifiers.verifyWidgetSize(
      tester: tester,
      finder: finder,
      expectedWidth: expectedWidth,
      expectedHeight: expectedHeight,
    );
  }
}
