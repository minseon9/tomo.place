import 'package:mocktail/mocktail.dart';

/// 테스트 전용 Mock 설정
void setupTestMocks() {
  // Mocktail fallback 값 등록
  registerFallbackValue(DateTime.now());
  registerFallbackValue('fallback_string');
  registerFallbackValue(0);
  registerFallbackValue(false);
}

/// 테스트 전용 DI 설정
void setupTestDependencies() {
  // GetIt 테스트 설정 (필요시)
  // Provider 테스트 설정 (필요시)
}

/// 테스트 환경 초기화
void main() {
  setupTestMocks();
  setupTestDependencies();
}
