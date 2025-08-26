# 토모플레이스 (Tomo.Place) Flutter App

> 의존성 분리와 Clean Architecture 기반의 소셜 로그인 앱

## 📱 프로젝트 개요

토모플레이스는 Figma 디자인 시스템을 기반으로 한 Flutter 앱으로, 컴포넌트 간 의존성을 최소화하고 도메인별 비즈니스 로직을 분리한 Clean Architecture를 적용했습니다.

### 주요 기능
- 소셜 로그인 (카카오, 애플, 구글, 이메일)
- 재사용 가능한 디자인 시스템
- 의존성 역전을 통한 테스트 용이성

## 🏗️ 아키텍처 원칙

### 핵심 설계 원칙
1. **의존성 역전 원칙**: 상위 레벨이 하위 레벨에 의존하지 않음
2. **단일 책임 원칙**: 각 컴포넌트는 하나의 책임만 가짐
3. **인터페이스 분리**: 클라이언트가 사용하지 않는 인터페이스에 의존하지 않음
4. **도메인 중심 설계**: 비즈니스 로직을 도메인별로 명확히 분리

### 계층별 의존성 규칙
```
Presentation Layer (UI)
         ↓ (의존)
Domain Layer (Business Logic)
         ↓ (의존)
Data Layer (External APIs, DB)
         ↓ (의존)
Infrastructure Layer (Framework Details)
```

## 📁 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── app/                         # 앱 레벨 설정
│   ├── app.dart                 # 메인 앱 위젯
│   ├── router/                  # 네비게이션 라우팅
│   └── di/                      # 의존성 주입 컨테이너
│       └── injection_container.dart
├── shared/                      # 공통 재사용 요소
│   ├── design_system/           # Figma 기반 디자인 시스템
│   │   ├── tokens/              # 디자인 토큰 (색상, 폰트, 간격)
│   │   ├── atoms/               # 기본 UI 요소 (버튼, 입력필드)
│   │   ├── molecules/           # atoms 조합 컴포넌트
│   │   └── organisms/           # molecules 조합 컴포넌트
│   ├── utils/                   # 순수 유틸리티 함수
│   └── widgets/                 # 범용 위젯 (비즈니스 로직 없음)
├── domains/                     # 도메인별 기능 분리
│   ├── auth/                    # 인증 도메인
│   ├── social_login/            # 소셜 로그인 도메인
│   └── user_profile/            # 사용자 프로필 도메인
└── infrastructure/              # 외부 의존성 구현
    ├── network/                 # API 클라이언트
    ├── storage/                 # 로컬 저장소
    └── external_services/       # 소셜 로그인 SDK
```

## 📂 디렉토리 상세 설명

### `/app` - 앱 레벨 설정
앱의 전역 설정과 초기화를 담당합니다.
- **app.dart**: MaterialApp 설정, 테마, 라우팅 연결
- **router/**: 페이지 네비게이션 규칙 정의
- **di/**: GetIt을 통한 의존성 주입 설정

### `/shared` - 공통 재사용 요소
프로젝트 전체에서 재사용되는 순수한 UI 컴포넌트와 유틸리티들입니다.

#### `/shared/design_system` - Figma 기반 디자인 시스템
- **tokens/**: Figma Variables에서 추출한 디자인 토큰
  - `colors.dart`: 브랜드 컬러, 소셜 로그인 컬러 등
  - `typography.dart`: 폰트 크기, 무게, 행간 정의
  - `spacing.dart`: 패딩, 마진 간격 시스템
  - `radius.dart`: 모서리 반지름 시스템

- **atoms/**: 가장 기본적인 UI 요소 (의존성 없음)
  - `buttons/`: BaseButton, ButtonVariants
  - `inputs/`: TextField, PasswordField
  - `indicators/`: LoadingIndicator, ProgressBar

- **molecules/**: atoms를 조합한 컴포넌트
  - `social_login_button.dart`: 아이콘 + 텍스트 + 버튼 조합
  - `form_field.dart`: 라벨 + 입력필드 + 에러 메시지

- **organisms/**: molecules를 조합한 복합 컴포넌트
  - `login_form.dart`: 여러 입력 필드와 버튼들의 조합
  - `social_login_section.dart`: 소셜 로그인 버튼들의 그룹

### `/domains` - 도메인별 기능 분리
각 비즈니스 도메인을 완전히 독립적으로 관리합니다.

#### `/domains/auth` - 인증 도메인
사용자 인증과 토큰 관리를 담당합니다.
```
auth/
├── domain/                      # 비즈니스 로직 (순수 Dart)
│   ├── entities/                # 핵심 비즈니스 객체
│   │   ├── user.dart           # 사용자 엔티티
│   │   └── auth_token.dart     # 인증 토큰 엔티티
│   ├── repositories/            # 데이터 액세스 인터페이스
│   │   └── auth_repository.dart
│   ├── usecases/               # 비즈니스 유스케이스
│   │   ├── authenticate_with_social.dart
│   │   ├── login_with_email.dart
│   │   └── logout_user.dart
│   └── value_objects/          # 도메인 값 객체
│       ├── email.dart
│       └── password.dart
├── data/                       # 데이터 레이어 구현
│   ├── datasources/            # 외부 데이터 소스
│   ├── models/                 # 데이터 전송 객체
│   └── repositories/           # Repository 구현체
└── presentation/               # UI 레이어
    ├── controllers/            # 상태 관리 (Cubit)
    ├── pages/                  # 화면 위젯
    └── widgets/                # 도메인 특화 위젯
```

#### `/domains/social_login` - 소셜 로그인 도메인
소셜 플랫폼별 인증을 독립적으로 처리합니다.
```
social_login/
├── domain/
│   ├── entities/
│   │   └── social_account.dart  # 소셜 계정 정보
│   ├── repositories/
│   │   └── social_auth_repository.dart
│   └── usecases/               # 플랫폼별 로그인 유스케이스
│       ├── kakao_login.dart
│       ├── google_login.dart
│       └── apple_login.dart
├── data/
│   ├── datasources/            # 각 소셜 SDK 래퍼
│   │   ├── kakao_datasource.dart
│   │   ├── google_datasource.dart
│   │   └── apple_datasource.dart
│   └── repositories/
└── presentation/
    └── widgets/                # 소셜 로그인 특화 위젯
```

### `/infrastructure` - 외부 의존성 구현
프레임워크나 외부 라이브러리에 의존하는 구현체들입니다.

#### `/infrastructure/network` - 네트워크 레이어
- **dio_client.dart**: HTTP 클라이언트 설정 (인터셉터, 에러 처리)
- **api_endpoints.dart**: API 엔드포인트 상수 관리

#### `/infrastructure/storage` - 저장소 레이어
- **secure_storage.dart**: 민감한 정보 암호화 저장 (토큰 등)
- **shared_preferences.dart**: 일반 설정 저장

#### `/infrastructure/external_services` - 외부 서비스 연동
- **kakao_service.dart**: 카카오 SDK 구체적 구현
- **google_service.dart**: 구글 SDK 구체적 구현
- **apple_service.dart**: 애플 SDK 구체적 구현

## 🔧 기술 스택

### 핵심 라이브러리
- **상태 관리**: `flutter_bloc` (Cubit 패턴)
- **의존성 주입**: `get_it`
- **네트워크**: `dio` + `retrofit`
- **로컬 저장소**: `flutter_secure_storage`
- **소셜 로그인**: `kakao_flutter_sdk`, `google_sign_in`, `sign_in_with_apple`

### 개발 도구
- **코드 생성**: `build_runner`, `retrofit_generator`
- **린팅**: `flutter_lints`
- **테스팅**: `mockito`, `bloc_test`

## 🚀 시작하기

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 코드 생성
```bash
flutter packages pub run build_runner build
```

### 3. 앱 실행
```bash
flutter run
```

## 📋 개발 가이드라인

### 새로운 기능 추가 시
1. **도메인 식별**: 기능이 속할 도메인 결정
2. **엔티티 정의**: `domain/entities/`에 비즈니스 객체 생성
3. **유스케이스 작성**: `domain/usecases/`에 비즈니스 로직 구현
4. **Repository 인터페이스**: `domain/repositories/`에 데이터 접근 인터페이스 정의
5. **데이터 레이어 구현**: `data/` 폴더에 구현체 작성
6. **UI 컴포넌트**: `presentation/`에 화면과 위젯 구현
7. **의존성 주입**: `app/di/`에 새로운 의존성 등록

### 컴포넌트 개발 원칙
- **Atoms**: 비즈니스 로직 없는 순수 UI
- **Molecules**: Atoms 조합, 여전히 순수 UI
- **Organisms**: 복잡한 UI 조합, 도메인 데이터 수용 가능
- **Pages**: 전체 화면, 상태 관리와 연결

## 🧪 테스트 전략

### Unit Tests
- **UseCase**: 각 비즈니스 로직 독립 테스트
- **Repository**: Mock을 통한 데이터 레이어 테스트
- **Utils**: 순수 함수 테스트

### Widget Tests
- **Atoms/Molecules**: 의존성 없는 UI 컴포넌트 테스트
- **Organisms**: Props 변화에 따른 렌더링 테스트

### Integration Tests
- **전체 플로우**: 로그인부터 홈 화면까지 E2E 테스트

## 📞 문의 및 기여

프로젝트에 대한 질문이나 기여를 원하시면 이슈를 생성해 주세요.

---

**설계 원칙을 준수하여 확장 가능하고 유지보수가 용이한 코드를 작성해 주세요!** 🚀