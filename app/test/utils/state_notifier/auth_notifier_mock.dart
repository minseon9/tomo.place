import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/auth/core/entities/authentication_result.dart';
import 'package:tomo_place/domains/auth/presentation/controllers/auth_notifier.dart';
import 'package:tomo_place/domains/auth/presentation/models/auth_state.dart';

import 'base_state_notifier_mock_factory.dart';

/// AuthNotifier Mock 클래스
class MockAuthNotifier extends Mock implements AuthNotifier {}

/// AuthState Mock 클래스
class MockAuthState extends Mock implements AuthState {}

/// Fake AuthNotifier 클래스
class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(FakeRef());
  
  @override
  Future<AuthenticationResult?> refreshToken(bool isLogin) async {
    // 테스트용 - null 반환
    return null;
  }
}

/// AuthNotifier Mock 팩토리 클래스
class AuthNotifierMockFactory {
  AuthNotifierMockFactory._();

  /// Mock AuthNotifier 생성
  static MockAuthNotifier createAuthNotifier() => MockAuthNotifier();

  /// Mock AuthState 생성
  static MockAuthState createAuthState() => MockAuthState();

  /// Fake AuthNotifier 생성
  static FakeAuthNotifier createFakeAuthNotifier() => FakeAuthNotifier();

  /// Mock Provider 생성
  static Provider<AuthNotifier> createMockProvider() {
    return BaseStateNotifierMockFactory.createMockProvider(() => createAuthNotifier());
  }

  /// Provider Override 생성
  static List<Override> createOverrides(Provider<AuthNotifier> provider) {
    return BaseStateNotifierMockFactory.createOverrides(provider, createAuthNotifier());
  }
}

