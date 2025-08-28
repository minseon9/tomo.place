# 토모플레이스 (Tomo.Place) Flutter App

> “누가 읽어도 구조와 규칙이 한눈에 보이는” 아키텍처 문서

## 📌 아키텍처 개요

이 프로젝트는 기능(도메인) 중심으로 구조화되며, UI/비즈니스/인프라 의존성을 명확히 분리합니다. 전역 라우팅은 `go_router`를 사용하고, 도메인별 라우트/상수는 각 도메인 내부에서 정의합니다. Design System은 도메인에 독립적이어야 하며, 비즈니스 타입/상수는 각 도메인의 `consts/`에 둡니다.

### 계층과 의존성 규칙
```
Presentation (UI, go_router routes)
          ↓
Services (비즈니스 로직, UseCase)
          ↓
Domain (consts, entities, repositories [interfaces])
          ↓
Data (datasources, models, repository impls)
          ↓
Shared Infrastructure (공통 인프라: network, storage, external services)
```
- **금지 규칙**
  - Domain → Presentation 역의존 금지
  - Design System → Domain 의존 금지(반대는 허용)
  - Presentation 내부에서 비즈니스 타입/상수 정의 금지(모두 `consts/`로)
  - 전역 라우터에 개별 페이지 직접 import 금지(가능한 도메인 라우트 조립)
  - 도메인별 Infrastructure 중복 금지(공통 인프라 사용)

## 📁 디렉터리 구조와 책임

```
lib/
├── main.dart                    # 앱 진입점
├── app/
│   ├── app.dart                 # MaterialApp.router + 전역 테마
│   ├── router/                  # go_router 조립(도메인 라우트 합성)
│   └── di/                      # 의존성 주입(GetIt)
├── shared/
│   ├── design_system/           # 도메인-독립 UI(토큰/atoms/molecules)
│   ├── infrastructure/          # 공통 인프라(네트워크/저장소/외부서비스)
│   │   ├── network/             # ApiClient, 인터셉터, 공통 네트워크 로직
│   │   ├── storage/             # TokenStorage, 공통 저장소 로직
│   │   └── external_services/   # OAuth, 외부 SDK 래퍼
│   ├── config/                  # 설정 관리(OAuth 설정, 환경변수)
│   ├── utils/                   # 순수 유틸리티
│   └── widgets/                 # 범용 위젯(비즈니스 로직 없음)
└── domains/
    ├── auth/
    │   ├── consts/              # enum/상수/경로 등
    │   ├── domain/              # 엔티티/레포 인터페이스(순수 Dart)
    │   ├── data/                # 데이터소스/모델/레포 구현체(간소화)
    │   ├── services/            # 비즈니스 로직(Service Layer)
    │   └── presentation/        # 페이지/컨트롤러/도메인 위젯/라우트
    └── user_profile/            # (동일한 패턴)
```

### 각 디렉터리의 책임
- **app/**: 앱 전역 부트스트랩. 라우터 조립, 테마, DI
- **shared/design_system/**: 색/타이포/spacing/버튼 등 “도메인 독립” UI
- **domains/<feature>/consts/**: enum/상수/경로/키(비즈니스 고정값)
- **domains/<feature>/domain/**: 엔티티/레포 인터페이스(순수 Dart)
- **domains/<feature>/data/**: 데이터소스/모델/레포 구현체(간소화)
- **domains/<feature>/services/**: 비즈니스 로직(Service Layer)
- **domains/<feature>/presentation/**: 페이지/위젯/상태(go_router 빌더 포함)

### 해야 할 것 / 하지 말아야 할 것(Do / Don’t)
- **Do**
  - UI는 도메인 `consts/`와 `services/`만 참조
  - 도메인별 라우트를 각 도메인 내부에 정의하고 앱 라우터에서 합성
  - 재사용 가능한 UI는 Design System에 배치(도메인 의존 금지)
- **Don’t**
  - UI 파일 안에 enum/상수/에러 정의 금지
  - Design System에서 특정 도메인 타입 import 금지
  - 전역 라우터에 모든 페이지를 직접 나열 금지
  - 도메인별 Infrastructure 중복 금지
  - Repository에 비즈니스 로직 포함 금지

## 🧭 라우팅 전략(go_router)

앱 레벨은 `MaterialApp.router` + `GoRouter` 조합을 사용합니다. 도메인별로 라우트 상수/빌더를 갖고, 전역 라우터는 이들을 합성합니다.

```dart
// lib/app/app.dart (요약)
MaterialApp.router(
  routerConfig: AppRouter.router,
)

// lib/app/router/app_router.dart (요약)
final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    // 도메인 라우트들을 여기로 합성하는 것이 원칙
  ],
);
```

### 도메인 라우트 작성 원칙
- 경로 상수는 `domains/<feature>/consts/routes.dart`
- `GoRoute` 목록은 `domains/<feature>/presentation/routes/<feature>_routes.dart`
- 앱 라우터는 각 도메인의 `routes`를 합성만 수행

## 🎨 Design System 규칙
- DS는 도메인 모듈을 import하지 않음
- DS 컴포넌트는 props만으로 동작(비즈니스 타입/레포 주입 금지)
- 도메인 종속 UI(예: SocialLoginButton)는 해당 도메인 `presentation/widgets/`로 이동

## 📦 비즈니스 상수/타입 관리
- 모든 enum/상수/경로/키는 `domains/<feature>/consts/` 하위에 배치
- UI/Controller는 반드시 `consts`를 import하여 사용
- 설정값은 `shared/config/`에서 환경변수 기반으로 관리

## 🔧 개발 및 품질 규칙
- 상태 관리: `flutter_bloc`(Cubit) 기준. UI-Service 간 의존은 인터페이스/DTO 중심
- DI: `get_it`에서 도메인 경계별 등록. 프레젠테이션에서 구현체 직접 의존 금지
- 네이밍: 기능을 드러내는 풀워드 사용, 축약 지양
- 에러 처리: 공통 에러 타입은 도메인별로 정의, UI에서 메시지 변환
- 아키텍처: Service Layer 패턴 적용, Repository는 단순 데이터 접근만 담당

## 🚀 시작하기
```bash
flutter pub get
flutter run
```

코드 생성 등을 사용하는 모듈에서만 별도 스텝(`build_runner`)을 수행하세요.

## 🧪 테스트 전략(요약)
- Unit: Service/Repository 인터페이스/유틸
- Widget: DS 컴포넌트/도메인 위젯
- Integration: 인증 플로우 등 E2E

---

문서를 기준으로 구조를 유지하세요. 위 규칙을 위반하면 리팩토링으로 되돌립니다.