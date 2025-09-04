/// 테스트용 고정 시간들
class TestTimes {
  TestTimes._();

  static final DateTime fixedTime = DateTime(2024, 1, 15, 12, 0, 0);
  static final DateTime pastTime = DateTime(2023, 6, 1, 9, 30, 0);
  static final DateTime futureTime = DateTime(2024, 12, 31, 23, 59, 59);
  
  // 토큰 만료 테스트용 시간들 (현재 로직에 맞춰 조정)
  static final DateTime tokenExpiredTime = DateTime(2024, 1, 15, 11, 0, 0); // 1시간 전
  static final DateTime tokenAboutToExpireTime = DateTime(2024, 1, 15, 12, 3, 0); // 3분 후 (5분 내 만료)
  static final DateTime tokenValidTime = DateTime(2024, 1, 15, 12, 10, 0); // 10분 후 (충분히 유효)
}
