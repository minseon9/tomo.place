# Flutter Testing Strategy & Conventions

## 📋 목차
1. [테스트 철학과 원칙](#테스트-철학과-원칙)
2. [테스트 레이어별 전략](#테스트-레이어별-전략)
3. [테스트 작성 컨벤션](#테스트-작성-컨벤션)
4. [Mocking 전략](#mocking-전략)
5. [테스트 도구와 설정](#테스트-도구와-설정)
6. [테스트 커버리지 전략](#테스트-커버리지-전략)
7. [CI/CD 통합](#cicd-통합)

---

## 🎯 테스트 철학과 원칙

### 핵심 원칙
- **테스트는 코드의 문서다**: 테스트를 통해 비즈니스 로직과 요구사항을 명확히 표현
- **빠른 피드백**: 개발 중 문제를 조기에 발견하여 디버깅 시간 단축
- **리팩토링 안전성**: 기존 기능이 깨지지 않았음을 보장
- **설계 품질**: 테스트하기 어려운 코드는 설계 개선의 신호

### Clean Architecture 테스트 원칙
- **Core Layer**: 순수한 비즈니스 로직만 테스트, 외부 의존성 Mock
- **Infrastructure Layer**: 외부 서비스 연동 로직 테스트, 실제 API 호출은 제한
- **Presentation Layer**: UI 로직과 상태 변화 테스트, UseCase Mock

---

## 🏗️ 테스트 레이어별 전략

### 1. Core Layer (Domain) 테스트

#### Entities 테스트
```dart
// ✅ Good: 비즈니스 규칙 검증
test('AuthToken.isExpired should return true when token is expired', () {
  final token = AuthToken(
    accessToken: 'token',
    refreshToken: 'refresh',
    accessTokenExpiresAt: DateTime.now().subtract(Duration(minutes: 1)),
    refreshTokenExpiresAt: DateTime.now().add(Duration(days: 7)),
  );
  
  expect(token.isAccessTokenExpired, isTrue);
  expect(token.isRefreshTokenValid, isTrue);
});

// ✅ Good: Factory 메서드 검증
test('AuthToken.fromJson should parse valid JSON correctly', () {
  final json = {
    'accessToken': 'access_token',
    'refreshToken': 'refresh_token',
    'accessTokenExpiresAt': '2024-12-31T23:59:59Z',
    'refreshTokenExpiresAt': '2025-12-31T23:59:59Z',
  };
  
  final token = AuthToken.fromJson(json);
  expect(token.accessToken, equals('access_token'));
  expect(token.tokenType, equals('Bearer')); // 기본값 검증
});
```

#### UseCases 테스트
```dart
// ✅ Good: 단일 책임과 비즈니스 로직 검증
test('StartupRefreshTokenUseCase should refresh expired token', () async {
  // Given
  final mockAuthRepo = MockAuthRepository();
  final mockTokenRepo = MockAuthTokenRepository();
  final expiredToken = AuthToken(/* expired token */);
  final newToken = AuthToken(/* fresh token */);
  
  when(() => mockTokenRepo.getCurrentToken()).thenAnswer((_) async => expiredToken);
  when(() => mockAuthRepo.refreshToken(any())).thenAnswer((_) async => newToken);
  when(() => mockTokenRepo.saveToken(any())).thenAnswer((_) async {});
  
  final useCase = StartupRefreshTokenUseCase(
    repository: mockAuthRepo,
    tokenRepository: mockTokenRepo,
  );
  
  // When
  final result = await useCase.execute();
  
  // Then
  expect(result.status, AuthenticationStatus.authenticated);
  expect(result.token, equals(newToken));
  verify(() => mockTokenRepo.saveToken(newToken)).called(1);
});

// ✅ Good: 에러 케이스 검증
test('StartupRefreshTokenUseCase should clear token on refresh failure', () async {
  // Given
  when(() => mockAuthRepo.refreshToken(any())).thenThrow(Exception('Network error'));
  when(() => mockTokenRepo.clearToken()).thenAnswer((_) async {});
  
  // When
  final result = await useCase.execute();
  
  // Then
  expect(result.status, AuthenticationStatus.unauthenticated);
  verify(() => mockTokenRepo.clearToken()).called(1);
});
```

#### Repository Interfaces 테스트
```dart
// ✅ Good: Contract 검증 (구현체 테스트에서)
test('AuthRepositoryImpl should implement AuthRepository contract', () {
  final repository = AuthRepositoryImpl(/* dependencies */);
  expect(repository, isA<AuthRepository>());
});
```

### 2. Infrastructure Layer 테스트

#### Repository Implementations 테스트
```dart
// ✅ Good: 외부 의존성 Mock, 실제 API 호출 없음
test('AuthRepositoryImpl should call API client with correct parameters', () async {
  // Given
  final mockApiClient = MockApiClient();
  final mockResponse = Response(
    data: {'accessToken': 'token', 'refreshToken': 'refresh'},
    statusCode: 200,
  );
  
  when(() => mockApiClient.post(any(), data: any(named: 'data')))
      .thenAnswer((_) async => mockResponse);
  
  final repository = AuthRepositoryImpl(mockApiClient);
  
  // When
  await repository.authenticate(
    provider: 'google',
    authorizationCode: 'code123',
  );
  
  // Then
  verify(() => mockApiClient.post('/auth/google', data: {
    'provider': 'google',
    'authorizationCode': 'code123',
  })).called(1);
});
```

#### OAuth Providers 테스트
```dart
// ✅ Good: OAuth 플로우 검증
test('GoogleAuthProvider should handle successful OAuth flow', () async {
  // Given
  final mockGoogleSignIn = MockGoogleSignIn();
  final mockAuthResult = MockGoogleSignInAuthentication();
  
  when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAuthResult);
  when(() => mockAuthResult.accessToken).thenReturn('google_access_token');
  
  final provider = GoogleAuthProvider(mockGoogleSignIn);
  
  // When
  final result = await provider.authenticate();
  
  // Then
  expect(result.accessToken, equals('google_access_token'));
  expect(result.provider, equals(SocialProvider.google));
});
```

### 3. Presentation Layer 테스트

#### Controllers (Cubit/Bloc) 테스트
```dart
// ✅ Good: 상태 변화와 UseCase 호출 검증
blocTest<AuthController, AuthState>(
  'emits [AuthLoading, AuthSuccess] when login succeeds',
  build: () {
    final mockUseCase = MockLoginWithSocialUseCase();
    when(() => mockUseCase.execute(any()))
        .thenAnswer((_) async => LoginResponse.success());
    return AuthController(mockUseCase);
  },
  act: (bloc) => bloc.loginWithSocial(SocialProvider.google),
  expect: () => [
    AuthLoading(),
    AuthSuccess(),
  ],
  verify: (bloc) {
    verify(() => bloc.loginUseCase.execute(SocialProvider.google)).called(1);
  },
);
```

#### Widgets 테스트
```dart
// ✅ Good: UI 렌더링과 사용자 상호작용 검증
testWidgets('SocialLoginButton should call onPressed when tapped', (tester) async {
  // Given
  bool buttonPressed = false;
  final button = SocialLoginButton(
    provider: SocialProvider.google,
    onPressed: () => buttonPressed = true,
  );
  
  // When
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: button)));
  await tester.tap(find.byType(SocialLoginButton));
  await tester.pump();
  
  // Then
  expect(buttonPressed, isTrue);
});

// ✅ Good: 상태에 따른 UI 변화 검증
testWidgets('LoginPage should show loading indicator during authentication', (tester) async {
  // Given
  final mockController = MockAuthController();
  when(() => mockController.state).thenReturn(AuthLoading());
  
  // When
  await tester.pumpWidget(MaterialApp(
    home: LoginPage(controller: mockController),
  ));
  
  // Then
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  expect(find.text('로그인 중...'), findsOneWidget);
});
```

---

## 📝 테스트 작성 컨벤션

### 파일 명명 규칙
```
test/
├── domains/
│   └── auth/
│       ├── core/
│       │   ├── entities/
│       │   │   └── auth_token_test.dart
│       │   ├── usecases/
│       │   │   └── login_with_social_usecase_test.dart
│       │   └── repositories/
│       │       └── auth_repository_test.dart
│       ├── infrastructure/
│       │   └── repositories/
│       │       └── auth_repository_impl_test.dart
│       └── presentation/
│           ├── controllers/
│           │   └── auth_controller_test.dart
│           └── widgets/
│               └── social_login_button_test.dart
└── shared/
    └── infrastructure/
        └── network/
            └── api_client_test.dart
```

### 테스트 구조 (AAA Pattern)
```dart
test('테스트 설명', () async {
  // Arrange (Given) - 테스트 데이터와 Mock 설정
  final mockRepository = MockAuthRepository();
  final useCase = LoginUseCase(mockRepository);
  final loginRequest = LoginRequest(email: 'test@example.com', password: 'password');
  
  when(() => mockRepository.login(loginRequest))
      .thenAnswer((_) async => LoginResponse.success());
  
  // Act (When) - 테스트 대상 메서드 실행
  final result = await useCase.execute(loginRequest);
  
  // Assert (Then) - 결과 검증
  expect(result.isSuccess, isTrue);
  verify(() => mockRepository.login(loginRequest)).called(1);
});
```

### 테스트 그룹화
```dart
group('LoginUseCase', () {
  late MockAuthRepository mockRepository;
  late LoginUseCase useCase;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });
  
  group('성공 케이스', () {
    test('유효한 자격증명으로 로그인 성공', () async {
      // 테스트 로직
    });
    
    test('토큰 저장 확인', () async {
      // 테스트 로직
    });
  });
  
  group('실패 케이스', () {
    test('잘못된 자격증명으로 로그인 실패', () async {
      // 테스트 로직
    });
    
    test('네트워크 오류 시 적절한 에러 반환', () async {
      // 테스트 로직
    });
  });
});
```

---

## 🎭 Mocking 전략

### Mocking 라이브러리 선택
- **mocktail**: 기본 선택 (빌드 없음, 간단한 사용법)
- **mockito**: 코드생성 필요, 강력한 타입 안전성
- **bloc_test**: BLoC/Cubit 테스트 전용

### Mock 생성 규칙
```dart
// ✅ Good: 명확한 Mock 클래스명
class MockAuthRepository extends Mock implements AuthRepository {}
class MockApiClient extends Mock implements ApiClient {}

// ❌ Bad: 모호한 이름
class MockRepo extends Mock implements AuthRepository {}
class MockClient extends Mock implements ApiClient {}
```

### Mock 설정 패턴
```dart
// ✅ Good: 구체적인 응답 설정
when(() => mockRepository.getUser(any())).thenAnswer((_) async => User(id: '1', name: 'John'));

// ✅ Good: 에러 상황 시뮬레이션
when(() => mockRepository.getUser(any())).thenThrow(NetworkException('Connection failed'));

// ✅ Good: 호출 횟수 검증
verify(() => mockRepository.saveUser(any())).called(1);
verifyNever(() => mockRepository.deleteUser(any()));

// ✅ Good: 인자 검증
verify(() => mockRepository.updateUser(
  argThat(isA<User>()),
)).called(1);
```

### 시간 의존성 Mocking
```dart
// ✅ Good: Clock 패턴으로 시간 의존성 제거
class AuthToken {
  final DateTime _expiresAt;
  final Clock _clock;
  
  AuthToken(this._expiresAt, {Clock? clock}) : _clock = clock ?? const Clock();
  
  bool get isExpired => _clock.now().isAfter(_expiresAt);
}

// 테스트에서
test('토큰 만료 확인', () {
  final fixedTime = DateTime(2024, 1, 1, 12, 0);
  final clock = Clock(() => fixedTime);
  final token = AuthToken(
    DateTime(2024, 1, 1, 11, 59), // 만료된 시간
    clock: clock,
  );
  
  expect(token.isExpired, isTrue);
});
```

---

## 🛠️ 테스트 도구와 설정

### 의존성 설정
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.3
  bloc_test: ^9.1.4
  golden_toolkit: ^0.15.0
  integration_test:
    sdk: flutter
```

### 테스트 실행 명령어
```bash
# 모든 테스트 실행
flutter test

# 특정 파일 테스트
flutter test test/domains/auth/core/usecases/login_usecase_test.dart

# 커버리지와 함께 실행
flutter test --coverage

# 특정 패턴의 테스트만 실행
flutter test --name="LoginUseCase"

# 테스트 결과를 파일로 저장
flutter test --reporter=json --reporter=expanded > test_results.txt
```

### 테스트 설정 파일
```dart
// test/setup.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 전역 Mock 설정
void setupTestMocks() {
  // Mocktail 설정
  registerFallbackValue(DateTime.now());
  registerFallbackValue('fallback_string');
}

// 테스트 전용 DI 설정
void setupTestDependencies() {
  // GetIt 테스트 설정
  // Provider 테스트 설정
}

void main() {
  setupTestMocks();
  setupTestDependencies();
}
```

---

## 📊 테스트 커버리지 전략

### 커버리지 목표
- **Core Layer**: 90% 이상 (비즈니스 로직 핵심)
- **Infrastructure Layer**: 80% 이상 (외부 의존성 연동)
- **Presentation Layer**: 70% 이상 (UI 로직)
- **전체 프로젝트**: 80% 이상

### 커버리지 측정 및 분석
```bash
# 커버리지 실행
flutter test --coverage

# HTML 리포트 생성 (선택사항)
genhtml coverage/lcov.info -o coverage/html

# 커버리지 임계치 설정 (very_good_cli 사용 시)
very_good test --coverage --min-coverage 80
```

### 커버리지 제외 대상
```yaml
# .coveragerc 또는 lcov.info 수정
# UI 관련 코드 (위젯 렌더링)
# main.dart
# generated 코드
# platform channel 코드
```

---

## 🔄 CI/CD 통합

### GitHub Actions 워크플로우
```yaml
name: Flutter Tests

on:
  push:
    paths: ['app/**']
  pull_request:
    paths: ['app/**']

jobs:
  test:
    runs-on: macos-latest
    defaults:
      run:
        working-directory: app
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests with coverage
        run: flutter test --coverage
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: app/coverage/lcov.info
          fail_ci_if_error: true
```

### 커버리지 서비스 연동
- **Codecov**: PR 코멘트, 상태체크, 트렌드 분석
- **Coveralls**: PR 상태체크, 배지 제공
- **GitHub Pages**: 커스텀 커버리지 리포트

---

## 🚀 테스트 작성 우선순위

### Phase 1: Core Layer (높은 우선순위)
1. **Entities**: 비즈니스 규칙과 데이터 검증
2. **UseCases**: 핵심 비즈니스 로직 검증
3. **Repository Interfaces**: 계약 검증

### Phase 2: Infrastructure Layer (중간 우선순위)
1. **Repository Implementations**: API 연동 로직 검증
2. **OAuth Providers**: 소셜 로그인 플로우 검증
3. **Network Layer**: HTTP 클라이언트 검증

### Phase 3: Presentation Layer (낮은 우선순위)
1. **Controllers**: 상태 관리 로직 검증
2. **Widgets**: UI 렌더링과 상호작용 검증
3. **Integration Tests**: 전체 플로우 검증

---

## 📚 참고 자료

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Bloc Test Package](https://pub.dev/packages/bloc_test)
- [Golden Toolkit](https://pub.dev/packages/golden_toolkit)
- [Very Good CLI](https://verygood.ventures/blog/very-good-cli)

---

## 🎯 다음 단계

1. **테스트 환경 설정**: mocktail, bloc_test 등 의존성 추가
2. **Core Layer 테스트 작성**: Entities, UseCases 우선
3. **Infrastructure Layer 테스트**: Repository 구현체들
4. **Presentation Layer 테스트**: Controllers, Widgets
5. **CI/CD 통합**: GitHub Actions 워크플로우 구성
6. **커버리지 모니터링**: Codecov 연동 및 임계치 설정

---

**"좋은 테스트는 코드의 품질을 보장하고, 개발자의 자신감을 높이며, 유지보수성을 크게 향상시킵니다."**
