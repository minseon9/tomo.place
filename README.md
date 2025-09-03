# Tomo Place

Flutter 기반의 위치 기반 서비스 애플리케이션

## 프로젝트 구조

### 도메인 기반 아키텍처 (Domain-Driven Design)

```
app/
├── lib/
│   ├── app/                          # 애플리케이션 설정 및 라우팅
│   ├── domains/                      # 도메인별 비즈니스 로직
│   │   ├── auth/                     # 인증 도메인
│   │   │   ├── core/                 # 도메인 핵심 (엔티티, 리포지토리 인터페이스, 유스케이스)
│   │   │   │   ├── entities/         # 도메인 엔티티
│   │   │   │   ├── repositories/     # 리포지토리 인터페이스
│   │   │   │   └── usecases/         # 비즈니스 유스케이스
│   │   │   ├── data/                 # 데이터 계층 (기존 infrastructure에서 리팩토링)
│   │   │   │   ├── datasources/      # 데이터 소스
│   │   │   │   │   ├── api/          # API 통신 관련
│   │   │   │   │   └── storage/      # 로컬 저장소 관련
│   │   │   │   ├── models/           # API 응답/요청 모델
│   │   │   │   ├── mappers/          # 엔티티 ↔ 모델 변환 로직
│   │   │   │   └── repositories/     # 리포지토리 구현체
│   │   │   └── presentation/         # 프레젠테이션 계층 (컨트롤러, 페이지)
│   │   ├── user/                     # 사용자 도메인
│   │   └── place/                    # 장소 도메인
│   └── shared/                       # 공통 인프라스트럭처
│       ├── config/                   # 애플리케이션 설정
│       ├── design_system/            # 디자인 시스템
│       ├── exceptions/               # 공통 예외 처리
│       ├── infrastructure/           # 공통 인프라스트럭처
│       │   ├── network/              # 네트워크 관련
│       │   └── storage/              # 저장소 관련
│       ├── utils/                    # 유틸리티
│       └── widgets/                  # 공통 위젯
```

## 아키텍처 특징

### 1. 계층 구조
- **Core**: 도메인 엔티티, 리포지토리 인터페이스, 유스케이스
- **Data**: 데이터 소스, 모델, 매퍼, 리포지토리 구현체
- **Presentation**: 컨트롤러, 페이지, 위젯

### 2. 데이터 소스 분리
- **API**: 서버 통신 담당 (`datasources/api/`)
- **Storage**: 로컬 저장소 담당 (`datasources/storage/`)

### 3. Mapper 패턴
- API 응답을 도메인 엔티티로 변환하는 로직 분리
- 엔티티와 모델 간의 명확한 책임 분리

### 4. 모듈화된 의존성 주입
- Shared, Auth 도메인별로 독립적인 DI 모듈
- 확장 가능한 구조

## 기술 스택

- **프레임워크**: Flutter
- **상태 관리**: Bloc
- **의존성 주입**: GetIt
- **네트워킹**: Dio
- **로컬 저장소**: Flutter Secure Storage
- **OAuth**: Google Sign-In, Apple Sign-In, Kakao Login

## 개발 환경 설정

```bash
# 의존성 설치
flutter pub get

# iOS 의존성 설치 (iOS 개발 시)
cd ios && pod install && cd ..

# 앱 실행
flutter run
```

## 아키텍처 원칙

1. **도메인 중심 설계**: 비즈니스 로직을 도메인별로 분리
2. **계층 분리**: Presentation, Domain, Data 계층의 명확한 분리
3. **의존성 역전**: 고수준 모듈이 저수준 모듈에 의존하지 않음
4. **단일 책임**: 각 클래스는 하나의 책임만 가짐
5. **테스트 용이성**: 각 계층을 독립적으로 테스트 가능
