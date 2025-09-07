import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider 테스트를 위한 유틸리티 클래스
class ProviderTestUtils {
  ProviderTestUtils._();

  /// ProviderContainer 생성 헬퍼
  static ProviderContainer createTestContainer({
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(overrides: overrides);
  }

  /// Widget을 ProviderScope로 감싸는 헬퍼
  static Widget wrapWithProviderScope({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: child,
    );
  }

  /// Widget을 MaterialApp과 ProviderScope로 감싸는 헬퍼
  static Widget wrapWithMaterialAppAndProviderScope({
    required Widget child,
    List<Override> overrides = const [],
    String title = 'Test App',
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        title: title,
        home: child,
      ),
    );
  }

  /// Provider 상태 변화 대기 헬퍼
  static Future<void> waitForProviderUpdate<T>(
    ProviderContainer container,
    ProviderListenable<T> provider,
    bool Function(T) condition, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<void>();
    late ProviderSubscription<T> subscription;

    subscription = container.listen(
      provider,
      (previous, next) {
        if (condition(next)) {
          subscription.close();
          completer.complete();
        }
      },
    );

    // 타임아웃 설정
    Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.close();
        completer.completeError(TimeoutException('Provider update timeout', timeout));
      }
    });

    return completer.future;
  }

  /// Provider 상태가 특정 값이 될 때까지 대기
  static Future<void> waitForProviderValue<T>(
    ProviderContainer container,
    ProviderListenable<T> provider,
    T expectedValue, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    return waitForProviderUpdate<T>(
      container,
      provider,
      (value) => value == expectedValue,
      timeout: timeout,
    );
  }
}
