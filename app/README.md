# Tomo.place

Flutter 기반의 소셜 로그인 앱으로, **Clean Architecture + Domain-Driven Design** 패턴을 적용하여 구조화된 프로젝트입니다.

## 🏗️ 프로젝트 아키텍처

### Clean Architecture 레이어 구조

```
🏛️ Clean Architecture (의존성 방향: 안쪽 → 바깥쪽)

┌─────────────────────────────────────────────────────────┐
│                    Presentation                         │  ← UI Layer
│  ┌─────────────────────────────────────────────────┐   │
│  │                 Infrastructure                   │   │  ← External Layer
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │              Core (Domain)                   │ │   │  ← Business Layer
│  │  │  • Entities • UseCases • Repositories       │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**🎯 핵심 원칙:**
- **의존성 역전**: 바깥 레이어가 안쪽 레이어에 의존 (반대 불가)
- **단일 책임**: 각 레이어는 하나의 명확한 책임만 가짐
- **인터페이스 분리**: Core는 추상화에만 의존, 구체적 구현 모름

---

## 📁 디렉토리 구조

### Flutter App (`app/`)

```
app/lib/
├── domains/auth/                   # 🎯 인증 도메인
│   ├── core/                       # 📚 Core Business Logic (가장 중요)
│   │   ├── entities/               # 🏷️ 도메인 엔티티 (비즈니스 객체)
│   │   │   ├── auth_token.dart     # JWT 토큰 관리
│   │   │   ├── social_provider.dart # 소셜 로그인 제공자 enum
│   │   │   ├── login_request.dart   # 로그인 요청 모델
│   │   │   └── signup_request.dart  # 회원가입 요청 모델
│   │   ├── usecases/               # 🎯 애플리케이션 비즈니스 로직
│   │   │   ├── login_with_social_usecase.dart    # 소셜 로그인 처리
│   │   │   ├── logout_usecase.dart               # 로그아웃 처리
│   │   │   ├── refresh_token_usecase.dart        # 토큰 갱신 처리
│   │   │   └── check_auth_status_usecase.dart    # 인증 상태 확인
│   │   └── repositories/           # 📝 Repository 인터페이스 (추상화)
│   │       └── auth_repository.dart
│   │
│   ├── infrastructure/             # 🔌 External Dependencies
│   │   ├── repositories/           # 💾 Repository 구현체
│   │   │   └── auth_repository_impl.dart
│   │   └── oauth/                  # 🔐 OAuth 구현체들
│   │       ├── oauth_provider.dart          # OAuth Provider 인터페이스
│   │       ├── oauth_provider_registry.dart # Provider 팩토리
│   │       └── providers/
│   │           └── google_auth_provider.dart # Google OAuth 구현
│   │
│   └── presentation/               # 🎨 UI Layer
│       ├── controllers/            # 🎮 상태 관리 (Cubit/Bloc)
│       │   └── auth_controller.dart
│       ├── pages/                  # 📱 화면들
│       │   └── signup_page.dart
│       ├── widgets/                # 🧩 재사용 위젯들
│       │   ├── social_login_button.dart
│       │   └── social_login_section.dart
│       └── models/                 # 📊 UI 전용 모델들 (DTO)
│           └── login_response.dart
│
├── shared/                         # 🤝 공통 모듈
│   ├── config/                     # ⚙️ 앱 설정
│   ├── design_system/              # 🎨 디자인 시스템
│   ├── exceptions/                 # ⚠️ 공통 예외 처리
│   │   ├── network_exception.dart
│   │   ├── server_exception.dart
│   │   ├── oauth_exception.dart
│   │   └── oauth_result.dart
│   ├── infrastructure/             # 🏗️ 공통 인프라
│   │   ├── network/api_client.dart # HTTP 클라이언트
│   │   └── storage/                # 로컬 저장소
│   └── widgets/                    # 🔧 공통 위젯들
│       └── error_dialog.dart
│
└── main.dart                       # 🚀 앱 진입점
```

### Backend (`tomo/`)

```
tomo/
├── auth/                           # 🔐 인증 모듈
├── user/                           # 👤 사용자 모듈  
├── common/                         # 🤝 공통 모듈
└── contract/                       # 📋 API 계약
```

---

## 🎯 각 레이어의 책임과 역할

### 1. **Core Layer** (가장 안쪽 - 비즈니스 규칙)

> **"순수한 비즈니스 로직만 포함, 외부 세계를 전혀 모름"**

#### 🏷️ **Entities** (`core/entities/`)
- **책임**: 비즈니스 핵심 객체와 규칙을 정의
- **특징**:
  - 외부 의존성 없음 (Flutter SDK도 최소한만 사용)
  - 비즈니스 로직과 데이터를 함께 캡슐화
  - 불변성(immutable) 원칙 준수

```dart
// ✅ Good: 비즈니스 로직이 포함된 Entity
class AuthToken {
  // 비즈니스 규칙: 토큰 만료 여부 판단
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isAboutToExpire => /* 5분 전 만료 로직 */;
}
```

#### 🎯 **UseCases** (`core/usecases/`)
- **책임**: 애플리케이션의 특정 비즈니스 액션 수행
- **원칙**:
  - 1 UseCase = 1 사용자 의도 (Single Responsibility)
  - Repository 인터페이스에만 의존
  - UI나 외부 시스템을 알지 못함

```dart
// ✅ Good: 단일 책임을 가진 UseCase
class LoginWithSocialUseCase {
  Future<LoginResponse?> execute(SocialProvider provider) async {
    // 1. OAuth 인증
    // 2. 서버 인증  
    // 3. 토큰 저장
    // 4. 사용자 정보 반환
  }
}
```

#### 📝 **Repositories** (`core/repositories/`)
- **책임**: 데이터 접근 계약 정의 (인터페이스만)
- **특징**:
  - 추상 클래스나 인터페이스만 포함
  - 구체적인 구현은 Infrastructure Layer에서 담당

---

### 2. **Infrastructure Layer** (가장 바깥쪽 - 구체적 구현)

> **"Core의 인터페이스를 구체적으로 구현, 외부 세계와 연결"**

#### 💾 **Repositories** (`infrastructure/repositories/`)
- **책임**: Core의 Repository 인터페이스를 실제로 구현
- **특징**:
  - API 호출, 데이터베이스 접근 등 구체적 구현
  - Core에서 정의한 인터페이스에 의존

```dart
// ✅ Good: 인터페이스를 구현하는 구체적 클래스
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient; // 외부 의존성 주입
  
  @override
  Future<AuthToken> authenticate(...) async {
    // API 호출 구체적 구현
  }
}
```

#### 🔐 **OAuth** (`infrastructure/oauth/`)
- **책임**: 소셜 로그인 제공자들과의 연동 구현
- **구조**:
  - `OAuthProvider`: 공통 인터페이스
  - `providers/`: 각 제공자별 구체적 구현 (Google, Apple, Kakao)
  - `OAuthProviderRegistry`: Provider 팩토리

---

### 3. **Presentation Layer** (UI 레이어)

> **"사용자와의 상호작용 처리, UseCase 호출하여 비즈니스 로직 실행"**

#### 🎮 **Controllers** (`presentation/controllers/`)
- **책임**: UI 상태 관리 및 UseCase와 UI 연결
- **특징**:
  - Cubit/Bloc 패턴 사용
  - UseCase들을 조합하여 복잡한 플로우 처리
  - UI 상태만 관리, 비즈니스 로직은 UseCase에 위임

```dart
// ✅ Good: UseCase를 호출하는 Controller
class AuthController extends Cubit<AuthState> {
  final LoginWithSocialUseCase _loginUseCase;
  
  Future<void> loginWithSocial(SocialProvider provider) async {
    emit(AuthLoading());
    final result = await _loginUseCase.execute(provider);
    // 결과에 따른 상태 변경
  }
}
```

#### 📱 **Pages & Widgets** (`presentation/pages/`, `presentation/widgets/`)
- **책임**: 사용자 인터페이스 렌더링
- **특징**:
  - Controller의 상태를 구독하여 UI 업데이트
  - 사용자 액션을 Controller에 전달

---

## 🔄 데이터 흐름 (Data Flow)

```
👤 User Input
    ↓
🎨 Presentation (Controller)
    ↓
🎯 Core (UseCase)
    ↓
📝 Core (Repository Interface)
    ↓
🔌 Infrastructure (Repository Implementation)
    ↓
🌐 External API/Services
```

### 예시: 소셜 로그인 플로우

```
1. 사용자가 "구글로 로그인" 버튼 클릭
   └── SocialLoginButton (Widget)

2. UI 이벤트가 Controller로 전달
   └── AuthController.loginWithSocial(SocialProvider.google)

3. Controller가 해당 UseCase 호출
   └── LoginWithSocialUseCase.execute(provider)

4. UseCase가 Repository 인터페이스 호출
   └── AuthRepository.authenticate(...)

5. Infrastructure가 실제 API 호출
   └── AuthRepositoryImpl → ApiClient → 서버

6. 결과가 역순으로 전파되어 UI 업데이트
   └── 성공 시: AuthSuccess 상태 → 홈 화면 이동
   └── 실패 시: AuthFailure 상태 → 에러 다이얼로그 표시
```

---

## 📏 개발 가이드라인

### ✅ **좋은 예시 (Do's)**

#### 의존성 방향 준수
```dart
// ✅ Core → Infrastructure (OK)
class LoginUseCase {
  final AuthRepository repository; // 인터페이스에 의존
}

// ✅ Presentation → Core (OK)  
class AuthController {
  final LoginUseCase loginUseCase; // UseCase에 의존
}
```

#### 단일 책임 원칙
```dart
// ✅ 하나의 명확한 책임
class LoginWithSocialUseCase {
  Future<Result> execute(SocialProvider provider) => ...;
}

class LogoutUseCase {
  Future<void> execute() => ...;
}
```

### ❌ **나쁜 예시 (Don'ts)**

#### 잘못된 의존성 방향
```dart
// ❌ Infrastructure → Presentation (절대 금지)
class AuthRepositoryImpl {
  final AuthController controller; // UI에 의존하면 안됨!
}

// ❌ Core → Infrastructure (절대 금지)
class LoginUseCase {
  final ApiClient apiClient; // 구체적 구현에 의존하면 안됨!
}
```

#### 책임 혼재
```dart
// ❌ UseCase에 UI 로직 포함
class LoginUseCase {
  Future<void> execute() {
    // 비즈니스 로직
    final result = await repository.login();
    
    // ❌ UI 처리는 UseCase 책임 아님
    if (result.success) {
      Navigator.pushReplacementNamed('/home');
    }
  }
}
```

---

## 🧪 테스트 전략

### Core Layer 테스트
```dart
// UseCase는 Repository를 Mock하여 독립적으로 테스트
test('로그인 성공 시 토큰을 저장해야 한다', () async {
  // Given
  final mockRepository = MockAuthRepository();
  final useCase = LoginWithSocialUseCase(mockRepository);
  
  // When
  final result = await useCase.execute(SocialProvider.google);
  
  // Then
  expect(result, isA<LoginResponse>());
  verify(mockRepository.authenticate).called(1);
});
```

### Presentation Layer 테스트
```dart
// Controller는 UseCase를 Mock하여 테스트
testWidgets('로그인 실패 시 에러 다이얼로그를 표시해야 한다', (tester) async {
  // Given
  final mockUseCase = MockLoginUseCase();
  when(mockUseCase.execute(any)).thenThrow(NetworkException());
  
  // When & Then
  // 위젯 테스트 로직
});
```

---

## 🚀 시작하기

### 개발 환경 설정
```bash
# Flutter 프로젝트 의존성 설치
cd app
flutter pub get

# 백엔드 빌드
cd ../tomo
./gradlew build
```

### 새로운 기능 추가 시 고려사항

1. **Entity 추가**: 새로운 비즈니스 개념이 필요한가?
2. **UseCase 추가**: 새로운 사용자 의도/액션이 있는가?
3. **Repository 확장**: 새로운 데이터 접근이 필요한가?
4. **Infrastructure 구현**: 외부 서비스 연동이 필요한가?

### 코드 리뷰 체크리스트

- [ ] 의존성 방향이 올바른가? (안쪽 → 바깥쪽)
- [ ] 각 클래스가 단일 책임을 갖는가?
- [ ] Core Layer에 외부 의존성이 없는가?
- [ ] UseCase가 비즈니스 로직만 포함하는가?
- [ ] 적절한 추상화가 적용되었는가?

---

## 🤝 기여하기

1. 이 문서를 먼저 읽고 아키텍처를 이해해주세요
2. 새로운 기능은 Clean Architecture 원칙을 준수해주세요
3. 코드 리뷰 시 아키텍처 가이드라인을 확인해주세요

---

**"좋은 아키텍처는 개발자의 생산성을 높이고, 버그를 줄이며, 코드의 수명을 연장합니다."**
