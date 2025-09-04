# Provider 리팩토링 계획

## 요청된 작업
- Provider들을 별개 파일로 분리된 구조를 개선하여 아키텍처에 맞게 재구성
- 핵심 엔티티는 기존 파일에 Provider 추가
- 복잡한 의존성을 가진 UseCase는 별도 파일
- 공통/공유 Provider는 별도 파일
- Riverpod와 Flutter 아키텍처 철학에 맞게 수정

## 현재 상황 분석

### 1. 현재 Provider 구조 문제점
- **과도한 파일 분리**: 각 Provider마다 별도 파일로 분리되어 있음
- **일관성 부족**: Provider 명명 규칙과 위치가 일관되지 않음
- **의존성 복잡성**: UseCase Provider들이 여러 의존성을 참조하여 복잡함
- **공유 리소스 분산**: 공통으로 사용되는 Provider들이 여러 곳에 산재

### 2. 현재 Provider 파일 목록
```
domains/auth/
├── data/repositories/auth_repository_provider.dart
├── data/repositories/auth_token_repository_provider.dart
├── data/datasources/api/auth_api_data_source_provider.dart
├── data/datasources/storage/auth_storage_data_source_provider.dart
├── core/usecases/usecase_providers.dart
├── core/usecases/check_refresh_token_status_usecase_provider.dart
├── core/usecases/startup_refresh_token_usecase_provider.dart
└── presentation/controllers/auth_notifier.dart

shared/
├── infrastructure/network/api_client_provider.dart
├── infrastructure/network/auth_interceptor_provider.dart
├── infrastructure/storage/token_storage_provider.dart
├── infrastructure/storage/access_token_memory_store_provider.dart
├── config/app_config_provider.dart
├── session/session_notifier.dart
├── errors/error_effects_provider.dart
└── navigation/navigation_providers.dart
```

## 리팩토링 계획

### 1. 핵심 원칙
1. **단순한 엔티티**: 구현체와 Provider를 같은 파일에 배치
2. **복잡한 UseCase**: 별도 providers 파일에서 관리
3. **공통 리소스**: shared/providers.dart에서 중앙 관리
4. **도메인별 그룹화**: 각 도메인 내에서 관련 Provider들을 그룹화

### 2. 새로운 구조 설계

#### 2.1 Auth 도메인 리팩토링

**A. Repository 구현체에 Provider 통합**
```dart
// domains/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository { ... }

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(authApiDataSourceProvider)),
);
```

**B. DataSource 구현체에 Provider 통합**
```dart
// domains/auth/data/datasources/api/auth_api_data_source.dart
class AuthApiDataSourceImpl implements AuthApiDataSource { ... }

final authApiDataSourceProvider = Provider<AuthApiDataSource>(
  (ref) {
    final client = ref.read(apiClientProvider);
    final interceptor = ref.read(authInterceptorProvider);
    client.addInterceptor(interceptor);
    return AuthApiDataSourceImpl(client);
  },
);
```

**C. UseCase Provider 통합**
```dart
// domains/auth/core/usecases/providers.dart
final signupWithSocialUseCaseProvider = Provider<SignupWithSocialUseCase>(...);
final logoutUseCaseProvider = Provider<LogoutUseCase>(...);
final checkRefreshTokenStatusUseCaseProvider = Provider<CheckRefreshTokenStatusUseCase>(...);
final startupRefreshTokenUseCaseProvider = Provider<StartupRefreshTokenUseCase>(...);
```

#### 2.2 Shared 모듈 리팩토링

**A. 공통 Provider 중앙화**
```dart
// shared/providers.dart
// Infrastructure
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) => TokenStorageService());
final accessTokenMemoryStoreProvider = Provider<AccessTokenMemoryStore>((ref) => AccessTokenMemoryStore());

// Configuration
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig());

// Session & Navigation
final sessionStateProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) => SessionNotifier());
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) => GlobalKey<NavigatorState>());
final navigationActionsProvider = Provider<NavigationActions>((ref) => NavigationActions(ref.watch(navigatorKeyProvider)));

// Error Handling
final errorEffectsProvider = StateNotifierProvider<ErrorEffects, ErrorInterface?>((ref) => ErrorEffects());
```

**B. 도메인별 그룹화**
```dart
// shared/infrastructure/providers.dart - 인프라 관련
// shared/session/providers.dart - 세션 관련  
// shared/navigation/providers.dart - 네비게이션 관련
// shared/errors/providers.dart - 에러 처리 관련
```

### 3. 단계별 실행 계획

#### Phase 1: Error Handling 통합 [우선순위: 높음]
1. **shared/error_handling/ 디렉토리 생성**
   - errors/와 exceptions/ 통합
   - models/, exceptions/, providers.dart 구조로 재구성

2. **Error 관련 Provider 통합**
   - errorEffectsProvider를 error_handling/providers.dart로 이동
   - 관련 Exception 클래스들 정리

#### Phase 2: Infrastructure Provider 통합 [우선순위: 높음]
1. **shared/infrastructure/providers.dart 생성**
   - Network, Storage 관련 모든 Provider 통합
   - apiClientProvider, tokenStorageServiceProvider 등

2. **기존 개별 Provider 파일들 제거**
   - api_client_provider.dart, token_storage_provider.dart 등

#### Phase 3: Application Services 재구성 [우선순위: 높음]
1. **shared/application/ 디렉토리 생성**
   - session/, navigation/ 서브디렉토리로 재구성
   - services/graceful_logout_handler.dart 리팩토링

2. **Application Provider 통합**
   - sessionStateProvider, navigationActionsProvider 등

#### Phase 4: UI Components 정리 [우선순위: 중간]
1. **shared/ui/ 디렉토리 생성**
   - widgets/를 components/로 재구성
   - design_system/ 유지

2. **UI 관련 Provider 정리**
   - 필요시 ui/providers.dart 생성

#### Phase 5: Auth 도메인 리팩토링 [우선순위: 높음]
1. **Repository 통합**
   - auth_repository_impl.dart에 Provider 추가
   - auth_repository_provider.dart 제거

2. **DataSource 통합**
   - auth_api_data_source.dart에 Provider 추가
   - auth_api_data_source_provider.dart 제거

3. **UseCase Provider 통합**
   - usecase_providers.dart에 모든 UseCase Provider 통합
   - 개별 UseCase Provider 파일들 제거

#### Phase 6: 정리 및 최적화 [우선순위: 낮음]
1. **불필요한 import 정리**
2. **Provider 의존성 최적화**
3. **테스트 코드 업데이트**
4. **문서 업데이트**

### 4. 파일 변경 상세 계획

#### 4.1 생성할 파일
```
shared/error_handling/
├── models/
│   ├── error_interface.dart
│   └── error_types.dart
├── exceptions/ (기존 파일들 이동)
├── providers.dart
└── handlers.dart

shared/infrastructure/providers.dart

shared/application/
├── session/session_notifier.dart
├── navigation/navigation_actions.dart
└── providers.dart

shared/ui/
├── components/ (기존 widgets/ 이동)
└── providers.dart (필요시)

domains/auth/core/usecases/providers.dart (기존 확장)
```

#### 4.2 수정할 파일
```
domains/auth/data/repositories/auth_repository_impl.dart (Provider 추가)
domains/auth/data/datasources/api/auth_api_data_source.dart (Provider 추가)
domains/auth/data/datasources/storage/auth_storage_data_source.dart (Provider 추가)
domains/auth/data/repositories/auth_token_repository_impl.dart (Provider 추가)
```

#### 4.3 제거할 파일
```
domains/auth/data/repositories/auth_repository_provider.dart
domains/auth/data/repositories/auth_token_repository_provider.dart
domains/auth/data/datasources/api/auth_api_data_source_provider.dart
domains/auth/data/datasources/storage/auth_storage_data_source_provider.dart
domains/auth/core/usecases/check_refresh_token_status_usecase_provider.dart
domains/auth/core/usecases/startup_refresh_token_usecase_provider.dart

shared/infrastructure/network/api_client_provider.dart
shared/infrastructure/network/auth_interceptor_provider.dart
shared/infrastructure/storage/token_storage_provider.dart
shared/infrastructure/storage/access_token_memory_store_provider.dart

shared/config/app_config_provider.dart
shared/session/session_notifier.dart (Provider 부분만)
shared/errors/error_effects_provider.dart
shared/navigation/navigation_providers.dart

shared/services/graceful_logout_handler.dart (리팩토링)
shared/widgets/ (components/로 이동)
shared/exceptions/ (error_handling/exceptions/로 이동)
```

### 5. 예상 효과

#### 5.1 장점
- **파일 수 감소**: 19개 → 약 8개 파일로 단순화
- **일관성 향상**: 명확한 Provider 배치 규칙
- **유지보수성 개선**: 관련 코드가 한 곳에 모임
- **의존성 관리 개선**: 공통 Provider 중앙 관리

#### 5.2 주의사항
- **Import 경로 변경**: 모든 참조 파일의 import 수정 필요
- **테스트 코드 업데이트**: Provider 참조 경로 변경
- **점진적 마이그레이션**: 한 번에 모든 파일을 변경하지 않고 단계적으로 진행

### 6. 검증 방법
1. **컴파일 확인**: 모든 Provider 참조가 올바르게 작동하는지 확인
2. **테스트 실행**: 기존 테스트들이 통과하는지 확인
3. **기능 테스트**: 앱의 주요 기능들이 정상 작동하는지 확인

## 다음 단계
1. 사용자 확인 및 피드백 수집
2. Phase 1부터 단계별 실행
3. 각 단계별 검증 및 테스트
4. 문서 업데이트 및 팀 공유
