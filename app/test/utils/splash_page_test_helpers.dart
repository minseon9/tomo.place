import 'package:mocktail/mocktail.dart';

import 'mock_factory/presentation_mock_factory.dart';

/// SplashPage 테스트용 헬퍼 함수들
class SplashPageTestHelpers {
  /// 정상 동작하는 AuthNotifier Mock 생성
  static MockAuthNotifier createSuccessAuthNotifier() {
    final mock = PresentationMockFactory.createAuthNotifier();
    when(() => mock.refreshToken(any())).thenAnswer((_) async => null);
    return mock;
  }

  /// 에러를 던지는 AuthNotifier Mock 생성
  static MockAuthNotifier createErrorAuthNotifier(String errorMessage) {
    final mock = PresentationMockFactory.createAuthNotifier();
    when(() => mock.refreshToken(any())).thenThrow(Exception(errorMessage));
    return mock;
  }

  /// 다양한 에러 타입별 Mock 생성
  static MockAuthNotifier createNetworkErrorAuthNotifier() {
    return createErrorAuthNotifier('Network error');
  }

  static MockAuthNotifier createTimeoutErrorAuthNotifier() {
    return createErrorAuthNotifier('Timeout');
  }

  static MockAuthNotifier createAuthErrorAuthNotifier() {
    return createErrorAuthNotifier('Authentication failed');
  }
}
