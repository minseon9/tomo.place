import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart';

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

  /// 토큰 만료 시나리오 테스트용 시간 고정
  static Future<T> withTokenExpiryScenario<T>(
    Future<T> Function() testFunction, {
    Duration? accessTokenExpiry,
    Duration? refreshTokenExpiry,
  }) async {
    final now = DateTime.now();
    final accessExpiry = accessTokenExpiry ?? const Duration(hours: 1);
    final refreshExpiry = refreshTokenExpiry ?? const Duration(days: 7);
    
    // 액세스 토큰이 만료되기 전 시간으로 고정
    final testTime = now.add(accessExpiry - const Duration(minutes: 10));
    
    return await withFrozenTime(testTime, testFunction);
  }

  /// 토큰 갱신 시나리오 테스트용 시간 고정
  static Future<T> withRefreshTokenScenario<T>(
    Future<T> Function() testFunction,
  ) async {
    final now = DateTime.now();
    // 액세스 토큰이 만료되기 3분 전 (갱신 필요 시점)
    final testTime = now.add(const Duration(minutes: 57)); // 1시간 - 3분
    
    return await withFrozenTime(testTime, testFunction);
  }

  /// Faker를 사용한 랜덤 시간 생성
  static DateTime generateRandomDateTime({
    DateTime? from,
    DateTime? to,
  }) {
    final start = from ?? DateTime.now().subtract(const Duration(days: 30));
    final end = to ?? DateTime.now().add(const Duration(days: 30));
    
    final random = faker.randomGenerator;
    final difference = end.difference(start).inMilliseconds;
    final randomMilliseconds = random.integer(difference);
    
    return start.add(Duration(milliseconds: randomMilliseconds));
  }

  /// 오늘 기준 상대적 시간 생성 헬퍼
  static DateTime daysFromNow(int days) {
    return DateTime.now().add(Duration(days: days));
  }

  static DateTime hoursFromNow(int hours) {
    return DateTime.now().add(Duration(hours: hours));
  }

  static DateTime minutesFromNow(int minutes) {
    return DateTime.now().add(Duration(minutes: minutes));
  }

  static DateTime daysAgo(int days) {
    return DateTime.now().subtract(Duration(days: days));
  }

  static DateTime hoursAgo(int hours) {
    return DateTime.now().subtract(Duration(hours: hours));
  }

  static DateTime minutesAgo(int minutes) {
    return DateTime.now().subtract(Duration(minutes: minutes));
  }

}
