import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestStyleVerifier {
  static void expectContainerPadding(
    WidgetTester tester,
    Finder finder,
    EdgeInsets expected,
  ) {
    final container = tester.widget<Container>(finder);
    expect(container.padding, equals(expected));
  }

  static void expectContainerDecoration(
    WidgetTester tester,
    Finder finder, {
    Color? color,
    double? borderRadius,
  }) {
    final container = tester.widget<Container>(finder);
    final decoration = container.decoration;
    expect(decoration, isA<BoxDecoration?>());
    final box = decoration as BoxDecoration?;
    if (color != null) {
      expect(box?.color, equals(color));
    }
    if (borderRadius != null) {
      final br = box?.borderRadius as BorderRadius?;
      expect(br, isNotNull);
      expect(br?.topLeft, equals(Radius.circular(borderRadius)));
      expect(br?.topRight, equals(Radius.circular(borderRadius)));
      expect(br?.bottomLeft, equals(Radius.circular(borderRadius)));
      expect(br?.bottomRight, equals(Radius.circular(borderRadius)));
    }
  }

  static void expectTextStyle(
    WidgetTester tester,
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? align,
  }) {
    final finder = find.text(text);
    expect(finder, findsAtLeastNWidgets(1));
    final actual = tester.widget<Text>(finder);
    final style = actual.style;
    if (color != null) expect(style?.color, equals(color));
    if (fontSize != null) expect(style?.fontSize, equals(fontSize));
    if (fontWeight != null) expect(style?.fontWeight, equals(fontWeight));
    if (align != null) expect(actual.textAlign, equals(align));
  }
}


