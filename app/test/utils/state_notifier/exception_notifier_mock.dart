import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/shared/exception_handler/exception_notifier.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_interface.dart';

import 'base_state_notifier_mock_factory.dart';

/// ExceptionNotifier Mock 클래스
class MockExceptionNotifier extends Mock implements ExceptionNotifier {}

/// ExceptionInterface Mock 클래스
class MockExceptionInterface extends Mock implements ExceptionInterface {}

/// Fake ExceptionNotifier 클래스
class FakeExceptionNotifier extends ExceptionNotifier {
  FakeExceptionNotifier() : super();
  
  @override
  void report(ExceptionInterface exception) {
    // 테스트용 - 아무것도 하지 않음
  }
  
  @override
  void clear() {
    // 테스트용 - 아무것도 하지 않음
  }
}

/// ExceptionNotifier Mock 팩토리 클래스
class ExceptionNotifierMockFactory {
  ExceptionNotifierMockFactory._();

  /// Mock ExceptionNotifier 생성
  static MockExceptionNotifier createExceptionNotifier() => MockExceptionNotifier();

  /// Mock ExceptionInterface 생성
  static MockExceptionInterface createExceptionInterface() => MockExceptionInterface();

  /// Fake ExceptionNotifier 생성
  static FakeExceptionNotifier createFakeExceptionNotifier() => FakeExceptionNotifier();

  /// Mock Provider 생성
  static Provider<ExceptionNotifier> createMockProvider() {
    return BaseStateNotifierMockFactory.createMockProvider(() => createExceptionNotifier());
  }

  /// Provider Override 생성
  static List<Override> createOverrides(Provider<ExceptionNotifier> provider) {
    return BaseStateNotifierMockFactory.createOverrides(provider, createExceptionNotifier());
  }
}
