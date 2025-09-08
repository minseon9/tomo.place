import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

/// 약관 관련 Mock 객체 팩토리
class TermsMockFactory {
  TermsMockFactory._();

  /// Mock VoidCallback 생성
  static MockVoidCallback createVoidCallback() {
    return MockVoidCallback();
  }

  /// Mock ValueChanged<bool?> 생성
  static MockValueChangedBool createValueChangedBool() {
    return MockValueChangedBool();
  }

  /// Mock NavigatorObserver 생성
  static MockNavigatorObserver createNavigatorObserver() {
    return MockNavigatorObserver();
  }

  /// Mock Route 생성
  static MockRoute createRoute() {
    return MockRoute();
  }

  /// Mock BuildContext 생성
  static MockBuildContext createBuildContext() {
    return MockBuildContext();
  }
}

/// Mock VoidCallback 클래스
class MockVoidCallback extends Mock {
  void call();
}

/// Mock ValueChanged<bool?> 클래스
class MockValueChangedBool extends Mock {
  void call(bool? value);
}

/// Mock NavigatorObserver 클래스
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

/// Mock Route 클래스
class MockRoute extends Mock implements Route<dynamic> {}

/// Mock BuildContext 클래스
class MockBuildContext extends Mock implements BuildContext {}
