import 'package:app/domains/auth/core/entities/authentication_result.dart';
import 'package:app/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:app/domains/auth/presentation/models/auth_state.dart';
import 'package:app/shared/application/navigation/navigation_actions.dart';
import 'package:app/shared/exception_handler/exception_notifier.dart';
import 'package:app/shared/exception_handler/models/exception_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

/// Presentation Layer Mock 클래스들
class MockAuthNotifier extends Mock implements AuthNotifier {}

class MockAuthState extends Mock implements AuthState {}

class MockExceptionInterface extends Mock implements ExceptionInterface {}

class MockExceptionNotifier extends Mock implements ExceptionNotifier{}

class MockNavigationActions extends Mock implements NavigationActions {}

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

/// Fake 객체들 - ref watch/read 등록 확인용
class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(FakeRef());
  
  @override
  Future<AuthenticationResult?> refreshToken(bool isLogin) async {
    // 테스트용 - null 반환
    return null;
  }
}

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

class FakeNavigationActions extends NavigationActions {
  FakeNavigationActions() : super(GlobalKey<NavigatorState>());
  
  @override
  void navigateToSignup() {
    // 테스트용 - 아무것도 하지 않음
  }
  
  @override
  void navigateToHome() {
    // 테스트용 - 아무것도 하지 않음
  }
  
  @override
  void showSnackBar(String message) {
    // 테스트용 - 아무것도 하지 않음
  }
}

/// Presentation Layer Mock 객체 생성을 위한 팩토리 클래스
class PresentationMockFactory {
  PresentationMockFactory._();

  // AuthNotifier Mock
  static MockAuthNotifier createAuthNotifier() => MockAuthNotifier();

  // AuthState Mock
  static MockAuthState createAuthState() => MockAuthState();

  // Exception Mock
  static MockExceptionInterface createExceptionInterface() => MockExceptionInterface();

  // ErrorEffects Mock
  static MockExceptionNotifier createExceptionNotifier() => MockExceptionNotifier();

  // NavigationActions Mock
  static MockNavigationActions createNavigationActions() => MockNavigationActions();

  // Fake 객체들
  static FakeAuthNotifier createFakeAuthNotifier() => FakeAuthNotifier();
  static FakeExceptionNotifier createFakeExceptionNotifier() => FakeExceptionNotifier();
  static FakeNavigationActions createFakeNavigationActions() => FakeNavigationActions();
}
