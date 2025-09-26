# 테스트 가이드라인

## 개요
이 문서는 프로젝트의 테스트 구조와 사용 가이드라인을 설명합니다.

## 테스트 유틸 구조

### 파일 네이밍 규칙
- 모든 테스트 유틸 파일은 `test_*_util.dart` 패턴을 따릅니다
- 도메인별 유틸: `test_auth_util.dart`, `test_terms_util.dart`
- 공용 UI 유틸: `test_actions_util.dart`, `test_wrappers_util.dart`, `test_verifiers_util.dart`
- 환경 유틸: `test_env_config_util.dart`

### 도메인별 유틸 설계 원칙
각 도메인 유틸(`test_*_util.dart`)은 다음을 포함합니다:
- **Mocks**: Mock 클래스 생성 및 관리
- **Fixtures**: 테스트 데이터 생성 (토큰, 결과, 예외 등)
- **Stubs**: 모킹 설정 헬퍼 (구체 인자 매칭 사용)
- **Provider Overrides**: Provider 오버라이드 리스트

## 사용 가이드라인

### 1. any() 사용 금지
```dart
// ❌ 나쁜 예
when(() => mockSignup.execute(any())).thenAnswer((_) async => token);

// ✅ 좋은 예
when(() => mockSignup.execute(SocialProvider.google)).thenAnswer((_) async => token);
```

### 2. fallback 등록 금지
```dart
// ❌ 나쁜 예
registerFallbackValue(AuthInitial());
registerFallbackValue(SocialProvider.google);

// ✅ 좋은 예
// fallback 등록 없이 구체 인자 매칭 사용
```

### 3. 도메인 유틸 사용
```dart
// ✅ 좋은 예
final mocks = AuthTestUtil.createMocks();
final token = AuthTestUtil.makeValidToken();
AuthTestUtil.stubSignupSuccess(mocks, provider: SocialProvider.google, token: token);

await tester.pumpWidget(ProviderScope(
  overrides: AuthTestUtil.providerOverrides(mocks),
  child: const TomoPlaceApp(),
));
```

### 4. 검증 유틸 사용
```dart
// ✅ 좋은 예
TestVerifiersUtil.expectRenders<SignupPage>();
TestVerifiersUtil.expectText('구글로 시작하기');
TestVerifiersUtil.expectSnackBar(message: '네트워크 오류');
```

### 5. 액션 유틸 사용
```dart
// ✅ 좋은 예
await TestActionsUtil.tapTextAndSettle(tester, '구글로 시작하기');
await TestActionsUtil.enterTextAndSettle(tester, finder, 'test@example.com');
```

## 테스트 작성 패턴

### 통합 테스트 구조
```dart
void main() {
  group('Feature Integration Test', () {
    late AuthMocks mocks;

    setUp(() {
      mocks = AuthTestUtil.createMocks();
    });

    Widget createTestApp({List<Override> overrides = const []}) {
      return ProviderScope(
        overrides: [
          ...AuthTestUtil.providerOverrides(mocks),
          ...overrides,
        ],
        child: const TomoPlaceApp(),
      );
    }

    testWidgets('시나리오 설명', (WidgetTester tester) async {
      // Given - 테스트 데이터 준비
      final token = AuthTestUtil.makeValidToken();
      AuthTestUtil.stubSignupSuccess(mocks, provider: SocialProvider.google, token: token);

      // When - 앱 시작 및 상호작용
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();
      await TestActionsUtil.tapTextAndSettle(tester, '구글로 시작하기');

      // Then - 검증
      TestVerifiersUtil.expectRenders<HomePage>();
      final container = ProviderScope.containerOf(tester.element(find.byType(TomoPlaceApp)));
      final authState = container.read(authNotifierProvider);
      expect(authState, isA<AuthSuccess>());
    });
  });
}
```

## 유틸별 책임

### TestActionsUtil
- 의미있는 액션+검증 중심
- settle 포함 액션 제공
- 단순 위임 메서드 제거

### TestWrappersUtil
- 위젯 래핑만 담당
- MaterialApp, Navigator, ScreenSize 설정

### TestVerifiersUtil
- 핵심 검증 기능만 제공
- 과도한 스타일 검증 축소

### AuthTestUtil
- Auth 도메인 전용
- mocks + fixtures + stubs 통합
- 구체 인자 매칭으로 테스트 의도 명확화

## 마이그레이션 가이드

### 기존 코드에서 새 유틸로 전환
1. `mock_factory/`, `fake_data/` import 제거
2. `test_auth_util.dart` import 추가
3. `any()` 사용을 구체 인자로 변경
4. fallback 등록 제거
5. `AuthTestUtil.stub*` 메서드 사용
6. `TestVerifiersUtil` 사용으로 검증 간소화

### 예시: Before → After
```dart
// Before
import '../utils/mock_factory/auth_mock_factory.dart';
import '../utils/fake_data/fake_auth_token_generator.dart';

when(() => mockSignup.execute(any())).thenAnswer((_) async => token);
registerFallbackValue(SocialProvider.google);

// After
import '../utils/test_auth_util.dart';

AuthTestUtil.stubSignupSuccess(mocks, provider: SocialProvider.google, token: token);
```

## 주의사항

1. **흐름 가시성**: 테스트 본문에서 비즈니스 흐름이 명확히 드러나야 함
2. **중복 제거**: 반복되는 모킹/검증 로직은 유틸로 축소
3. **의도 명확화**: any() 대신 구체 인자로 테스트 의도 표현
4. **유지보수성**: 도메인별 단일 유틸로 변경 영향 최소화
