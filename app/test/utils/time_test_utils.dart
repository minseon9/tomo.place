import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

/// 시간 관련 테스트 유틸리티
class TimeTestUtils {
  TimeTestUtils._();

  /// 특정 시간으로 고정하여 테스트 실행
  static Future<T> withFrozenTime<T>(
    DateTime frozenTime,
    Future<T> Function() testFunction,
  ) async {
    return await withClock(
      Clock.fixed(frozenTime),
      testFunction,
    );
  }

  /// 현재 시간으로부터 특정 시간만큼 미래로 고정
  static Future<T> withFrozenTimeFromNow<T>(
    Duration offset,
    Future<T> Function() testFunction,
  ) async {
    final frozenTime = DateTime.now().add(offset);
    return await withFrozenTime(frozenTime, testFunction);
  }

  /// 현재 시간으로부터 특정 시간만큼 과거로 고정
  static Future<T> withFrozenTimeInPast<T>(
    Duration offset,
    Future<T> Function() testFunction,
  ) async {
    final frozenTime = DateTime.now().subtract(offset);
    return await withFrozenTime(frozenTime, testFunction);
  }

  /// 특정 시간으로 고정하여 동기 함수 실행
  static T withFrozenTimeSync<T>(
    DateTime frozenTime,
    T Function() testFunction,
  ) {
    return withClock(
      Clock.fixed(frozenTime),
      testFunction,
    );
  }

}
