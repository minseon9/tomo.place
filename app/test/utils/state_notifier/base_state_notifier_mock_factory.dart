import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

/// StateNotifier Mock을 위한 기본 클래스
abstract class BaseStateNotifierMock<T> extends Mock implements StateNotifier<T> {
  BaseStateNotifierMock() : super();
}

/// Fake Ref 클래스 - 테스트용
class FakeRef extends Mock implements Ref {
  @override
  T read<T>(ProviderListenable<T> provider) {
    // 테스트용 기본값 반환
    return provider as T;
  }
  
  @override
  T watch<T>(ProviderListenable<T> provider) {
    return read(provider);
  }
  
  @override
  ProviderSubscription<T> listen<T>(
    ProviderListenable<T> provider, 
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    // 테스트용 - 빈 subscription 반환
    return MockProviderSubscription<T>();
  }
}

/// Mock ProviderSubscription 클래스
class MockProviderSubscription<T> extends Mock implements ProviderSubscription<T> {
  @override
  void close() {
    // 테스트용 - 아무것도 하지 않음
  }
}

/// StateNotifier Mock 생성을 위한 기본 팩토리 클래스
abstract class BaseStateNotifierMockFactory {
  BaseStateNotifierMockFactory._();
  
  /// Mock Provider 생성 헬퍼
  static Provider<T> createMockProvider<T>(T Function() mockFactory) {
    return Provider<T>((ref) => mockFactory());
  }
  
  /// Provider Override 헬퍼
  static List<Override> createOverrides<T>(Provider<T> provider, T mockInstance) {
    return [provider.overrideWith((ref) => mockInstance)];
  }
}
