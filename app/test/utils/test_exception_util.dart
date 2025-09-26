import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_interface.dart';

class MockExceptionNotifier extends Mock implements ExceptionNotifier {}

class TestExceptionUtil {
  TestExceptionUtil._();

  static MockExceptionNotifier createMockNotifier() {
    final mock = MockExceptionNotifier();
    when(mock.clear).thenReturn(null);
    return mock;
  }

  static void stubReport(MockExceptionNotifier mock, {ExceptionInterface? result}) {
    when(() => mock.report(any())).thenAnswer((invocation) {
      final error = invocation.positionalArguments.first;
      if (error is ExceptionInterface && result != null) {
        mock.state = result;
      }
    });
  }

  static void stubRead(MockExceptionNotifier mock, {ExceptionInterface? state}) {
    when(() => mock.state).thenReturn(state);
  }

  static Override overrideProvider(MockExceptionNotifier mock) {
    return exceptionNotifierProvider.overrideWith((_) => mock);
  }
}
