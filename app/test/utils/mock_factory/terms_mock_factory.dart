import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

class TermsMockFactory {
  TermsMockFactory._();

  static MockVoidCallback createVoidCallback() {
    return MockVoidCallback();
  }

  static MockValueChangedBool createValueChangedBool() {
    return MockValueChangedBool();
  }

  static MockNavigatorObserver createNavigatorObserver() {
    return MockNavigatorObserver();
  }

  static MockRoute createRoute() {
    return MockRoute();
  }

  static MockBuildContext createBuildContext() {
    return MockBuildContext();
  }

  static MockTermsPageLayoutCallbacks createTermsPageLayoutCallbacks() {
    return MockTermsPageLayoutCallbacks();
  }

  static MockTermsContentCallbacks createTermsContentCallbacks() {
    return MockTermsContentCallbacks();
  }

  static MockCloseButtonCallbacks createCloseButtonCallbacks() {
    return MockCloseButtonCallbacks();
  }

  static MockFunction<T, R> createFunction<T, R>() {
    return MockFunction<T, R>();
  }
}

class MockVoidCallback extends Mock {
  void call();
}

class MockValueChangedBool extends Mock {
  void call(bool? value);
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRoute extends Mock implements Route<dynamic> {}

class MockBuildContext extends Mock implements BuildContext {}

class MockTermsPageLayoutCallbacks extends Mock {
  void onClose();

  void onAgree();
}

class MockTermsContentCallbacks extends Mock {
  void onScroll();

  void onContentTap();
}

class MockCloseButtonCallbacks extends Mock {
  void onPressed();
}

class MockFunction<T, R> extends Mock {
  R call(T arg);
}
