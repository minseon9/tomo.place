import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 위젯 테스트를 위한 Finder 유틸리티
class WidgetFinders {
  WidgetFinders._();

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
