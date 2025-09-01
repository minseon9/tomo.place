# 구글 로그인 구현 실행 계획

## 요청된 작업
Spring Boot API 문서를 바탕으로 구글 로그인 기능을 구현하고, API 통신과 에러 처리 등 공통 로직을 shared에 정의하여 리팩토링

## 식별된 컨텍스트
- Spring Boot OIDC API 엔드포인트: `/api/oidc/login`, `/api/oidc/signup`
- 요청 스키마: `OIDCLoginRequestBody` (provider: "GOOGLE", authorizationCode)
- 응답 스키마: `LoginResponseBody` (token, refreshToken)
- 현재 Flutter 앱 구조: auth 도메인에 소셜 로그인 로직이 통합되어 있음
- 구글 로그인 버튼은 현재 비활성화 상태

## 실행 계획

### Phase 1: 구글 로그인 API 정의 및 기본 연동

#### 1. API 응답 모델 정의 [Pending]
**파일**: `lib/domains/auth/domain/entities/`

**생성할 파일들**:
- `login_request.dart`
- `signup_request.dart` 
- `login_response.dart`

**코드 예시**:
```dart
// lib/domains/auth/domain/entities/login_request.dart
class LoginRequest {
  final String provider; // "GOOGLE"
  final String authorizationCode;
  
  const LoginRequest({
    required this.provider,
    required this.authorizationCode,
  });
  
  Map<String, dynamic> toJson() => {
    'provider': provider,
    'authorizationCode': authorizationCode,
  };
}

// lib/domains/auth/domain/entities/signup_request.dart
class SignupRequest {
  final String provider; // "GOOGLE"
  final String authorizationCode;
  
  const SignupRequest({
    required this.provider,
    required this.authorizationCode,
  });
  
  Map<String, dynamic> toJson() => {
    'provider': provider,
    'authorizationCode': authorizationCode,
  };
}

// lib/domains/auth/domain/entities/login_response.dart
class LoginResponse {
  final String token;
  final String refreshToken;
  
  const LoginResponse({
    required this.token,
    required this.refreshToken,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
```

#### 2. 구글 OAuth2 플로우 구현 [Pending]
**파일**: `pubspec.yaml`, `lib/shared/infrastructure/external_services/`

**패키지 추가**:
```yaml
dependencies:
  url_launcher: ^6.2.5
  webview_flutter: ^4.7.0
  crypto: ^3.0.3
  shared_preferences: ^2.2.2
```

**생성할 파일들**:
- `lib/shared/config/app_config.dart` - 앱 설정 관리
- `lib/shared/config/oauth_config.dart` - OAuth 설정 관리
- `lib/shared/infrastructure/network/api_client.dart` - 공통 API 클라이언트
- `lib/shared/infrastructure/storage/token_storage_service.dart` - 토큰 저장 서비스
- `lib/shared/infrastructure/external_services/oauth_service.dart` - OAuth 서비스

**구글 OAuth2 플로우**:
1. 구글 계정 선택/로그인 화면으로 이동
2. 구글 계정 선택/로그인
3. authentication code 수신
4. state 검증
5. 서버에 회원가입 요청
6. 토큰 저장

**개선된 아키텍처 적용**:
- 공통 인프라 중앙화
- 런타임 설정 관리
- Provider 확장성 고려
- 보안 강화 (토큰 암호화 저장)

#### 3. Repository 구현체 업데이트 [Pending]
**파일**: `lib/domains/auth/data/repositories/`

**생성할 파일**:
- `auth_repository_impl.dart`

**개선된 아키텍처 적용**:
- Repository는 단순한 데이터 접근만 담당
- 공통 ApiClient 사용
- 도메인별 특화 예외 처리

**코드 예시**:
```dart
// lib/domains/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  
  AuthRepositoryImpl(this._apiClient);
  
  @override
  Future<User> authenticate(String provider, String code) async {
    final data = await _apiClient.post(
      '/api/oidc/login',
      {'provider': provider, 'authorizationCode': code},
      (json) => User.fromJson(json),
    );
    return data;
  }
  
  @override
  Future<User> register(String provider, String code) async {
    final data = await _apiClient.post(
      '/api/oidc/signup',
      {'provider': provider, 'authorizationCode': code},
      (json) => User.fromJson(json),
    );
    return data;
  }
}
```

#### 4. Service Layer 구현 [Pending]
**파일**: `lib/domains/auth/services/`

**생성할 파일**:
- `auth_service.dart`

**개선된 아키텍처 적용**:
- Service Layer에서 비즈니스 로직 처리
- OAuth 플로우와 토큰 관리 담당
- Repository는 단순 데이터 접근만 담당

**코드 예시**:
```dart
// lib/domains/auth/services/auth_service.dart
class AuthService {
  final AuthRepository _repository;
  final TokenStorageService _tokenStorage;
  final OAuthService _oauthService;
  
  AuthService({
    required AuthRepository repository,
    required TokenStorageService tokenStorage,
    required OAuthService oauthService,
  }) : _repository = repository,
       _tokenStorage = tokenStorage,
       _oauthService = oauthService;
  
  /// 구글 로그인
  Future<User> loginWithGoogle() async {
    try {
      // 1. OAuth 플로우로 인증 코드 획득
      final authCode = await _oauthService.authenticate('GOOGLE');
      
      // 2. 서버에 인증 요청
      final user = await _repository.authenticate('GOOGLE', authCode);
      
      // 3. 토큰 저장
      await _tokenStorage.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      
      return user;
    } catch (e) {
      throw AuthException('구글 로그인에 실패했습니다: ${e.toString()}');
    }
  }
  
  /// 구글 회원가입
  Future<User> signupWithGoogle() async {
    try {
      // 1. OAuth 플로우로 인증 코드 획득
      final authCode = await _oauthService.authenticate('GOOGLE');
      
      // 2. 서버에 회원가입 요청
      final user = await _repository.register('GOOGLE', authCode);
      
      // 3. 토큰 저장
      await _tokenStorage.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      
      return user;
    } catch (e) {
      throw AuthException('구글 회원가입에 실패했습니다: ${e.toString()}');
    }
  }
}
```

#### 5. Repository 구현체 업데이트 [Pending]
**파일**: `lib/domains/auth/data/repositories/`

**생성할 파일**:
- `auth_repository_impl.dart`

**개선된 아키텍처 적용**:
- Repository는 단순한 데이터 접근만 담당
- 비즈니스 로직은 Service Layer로 분리
- 공통 인프라 사용

**코드 예시**:
```dart
// lib/domains/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  
  AuthRepositoryImpl(this._apiClient);
  
  @override
  Future<User> authenticate(String provider, String code) async {
    final data = await _apiClient.post(
      '/api/oidc/login',
      {'provider': provider, 'authorizationCode': code},
      (json) => User.fromJson(json),
    );
    return data;
  }
  
  @override
  Future<User> register(String provider, String code) async {
    final data = await _apiClient.post(
      '/api/oidc/signup',
      {'provider': provider, 'authorizationCode': code},
      (json) => User.fromJson(json),
    );
    return data;
  }
  
  @override
  Future<User?> getCurrentUser() async {
    try {
      final data = await _apiClient.get(
        '/api/users/me',
        (json) => User.fromJson(json),
      );
      return data;
    } catch (e) {
      return null; // 인증되지 않은 경우
    }
  }
  
  @override
  Future<void> logout() async {
    await _apiClient.post(
      '/api/auth/logout',
      {},
      (json) => json,
    );
  }
}
```

#### 6. 구글 로그인 버튼 활성화 [Pending]
**파일**: `lib/domains/auth/services/`

**생성할 파일**:
- `auth_service.dart`

**개선된 아키텍처 적용**:
- Service Layer에서 비즈니스 로직 처리
- Repository는 단순 데이터 접근만 담당
- OAuth 플로우와 토큰 관리는 Service에서 처리

**코드 예시**:
```dart
// lib/domains/auth/services/auth_service.dart
class AuthService {
  final AuthRepository _repository;
  final TokenStorageService _tokenStorage;
  final OAuthService _oauthService;
  
  AuthService({
    required AuthRepository repository,
    required TokenStorageService tokenStorage,
    required OAuthService oauthService,
  }) : _repository = repository,
       _tokenStorage = tokenStorage,
       _oauthService = oauthService;
  
  /// 구글 로그인
  Future<User> loginWithGoogle() async {
    try {
      // 1. OAuth 플로우로 인증 코드 획득
      final authCode = await _oauthService.authenticate('GOOGLE');
      
      // 2. 서버에 인증 요청
      final user = await _repository.authenticate('GOOGLE', authCode);
      
      // 3. 토큰 저장
      await _tokenStorage.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      
      return user;
    } catch (e) {
      throw AuthException('구글 로그인에 실패했습니다: ${e.toString()}');
    }
  }
  
  /// 구글 회원가입
  Future<User> signupWithGoogle() async {
    try {
      // 1. OAuth 플로우로 인증 코드 획득
      final authCode = await _oauthService.authenticate('GOOGLE');
      
      // 2. 서버에 회원가입 요청
      final user = await _repository.register('GOOGLE', authCode);
      
      // 3. 토큰 저장
      await _tokenStorage.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      
      return user;
    } catch (e) {
      throw AuthException('구글 회원가입에 실패했습니다: ${e.toString()}');
    }
  }
  
  /// 로그아웃
  Future<void> logout() async {
    try {
      await _repository.logout();
      await _tokenStorage.clearTokens();
    } catch (e) {
      // 로그아웃 실패해도 토큰은 삭제
      await _tokenStorage.clearTokens();
      throw AuthException('로그아웃에 실패했습니다: ${e.toString()}');
    }
  }
  
  /// 현재 사용자 조회
  Future<User?> getCurrentUser() async {
    return await _repository.getCurrentUser();
  }
}
```

#### 7. Controller 업데이트 [Pending]
**파일**: `lib/domains/auth/presentation/controllers/auth_controller.dart`

**업데이트 내용**:
```dart
// Service Layer 사용으로 변경
class AuthController extends Cubit<AuthState> {
  AuthController({
    required AuthService authService,
  }) : _authService = authService,
       super(const AuthInitial());

  final AuthService _authService;

  /// 구글 로그인
  Future<void> loginWithGoogle() async {
    await _performSocialAuth(
      authMethod: () => _authService.loginWithGoogle(),
      provider: 'Google',
    );
  }

  /// 구글 회원가입
  Future<void> signupWithGoogle() async {
    await _performSocialAuth(
      authMethod: () => _authService.signupWithGoogle(),
      provider: 'Google',
    );
  }

  /// 소셜 인증 공통 로직
  Future<void> _performSocialAuth({
    required Future<User> Function() authMethod,
    required String provider,
  }) async {
    try {
      emit(const AuthLoading());
      
      final user = await authMethod();
      
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(
        message: '$provider 인증에 실패했습니다: ${e.toString()}',
        provider: provider.toLowerCase(),
      ));
      
      // TODO: 팝업 메시지 표시 로직 추가
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      emit(const AuthLoading());
      
      await _authService.logout();
      
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthFailure(
        message: '로그아웃에 실패했습니다: ${e.toString()}',
      ));
    }
  }
}
```

#### 8. 구글 로그인 버튼 활성화 [Pending]
**파일**: `lib/domains/auth/presentation/widgets/social_login_button.dart`

**업데이트 내용**:
```dart
bool get _isDisabled {
  switch (provider) {
    case SocialProvider.kakao:
    case SocialProvider.apple:
      return true; // 아직 지원하지 않음
    case SocialProvider.google:
      return false; // 활성화
    case SocialProvider.email:
      return false;
  }
}
```

#### 9. 토큰 저장 서비스 구현 [Pending]
**파일**: `lib/infrastructure/storage/`

**생성할 파일**:
- `token_storage_service.dart`

**코드 예시**:
```dart
// lib/infrastructure/storage/token_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  /// 토큰 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  /// Access Token 조회
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
  
  /// Refresh Token 조회
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  /// 토큰 삭제 (로그아웃 시)
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
```

#### 10. 기본 동작 테스트 [Pending]
**테스트 항목**:
- 구글 OAuth2 플로우 동작 확인
- 서버 API 호출 확인
- 토큰 저장 확인
- 에러 처리 확인
- 팝업 메시지 표시 확인

### Phase 2: 공통 로직 리팩토링

#### 11. 네트워크 공통 모듈 생성 [Pending]
**디렉토리**: `lib/shared/network/`

**생성할 파일들**:
- `api_client.dart`
- `api_exception.dart`
- `network_result.dart`

**코드 예시**:
```dart
// lib/shared/network/api_client.dart
class ApiClient {
  final Dio _dio;
  
  ApiClient({required String baseUrl}) : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  Future<NetworkResult<T>> get<T>(String path) async {
    try {
      final response = await _dio.get(path);
      return NetworkResult.success(response.data);
    } on DioException catch (e) {
      return NetworkResult.failure(ApiException.fromDioException(e));
    }
  }
}
```

#### 12. 에러 처리 공통화 [Pending]
**디렉토리**: `lib/shared/error/`

**생성할 파일들**:
- `app_exception.dart`
- `error_handler.dart`

**코드 예시**:
```dart
// lib/shared/error/app_exception.dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
}

class ApiException extends AppException {
  final int? statusCode;
  
  const ApiException(super.message, {this.statusCode});
}
```

#### 13. API 응답 래퍼 생성 [Pending]
**파일**: `lib/shared/network/api_response.dart`

**코드 예시**:
```dart
class ApiResponse<T> {
  final T data;
  final String? message;
  final bool success;
  
  const ApiResponse({
    required this.data,
    this.message,
    required this.success,
  });
  
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse(
      data: fromJson(json['data'] ?? json),
      message: json['message'],
      success: json['success'] ?? true,
    );
  }
}
```

#### 14. 기존 코드 리팩토링 [Pending]
**업데이트할 파일들**:
- `auth_api_service_impl.dart` - 공통 모듈 사용
- `social_auth_repository_impl.dart` - 에러 처리 통합

#### 15. DI 컨테이너 업데이트 [Pending]
**파일**: `lib/app/di/injection_container.dart`

**업데이트 내용**:
```dart
// 개선된 아키텍처에 맞는 의존성 등록
// 공통 인프라
sl.registerLazySingleton<ApiClient>(() => ApiClient(baseUrl: 'http://127.0.0.1:8080'));
sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());
sl.registerLazySingleton<OAuthService>(() => OAuthServiceImpl());

// Auth 도메인
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
sl.registerLazySingleton<AuthService>(() => AuthService(
  repository: sl(),
  tokenStorage: sl(),
  oauthService: sl(),
));

// Presentation Layer
sl.registerFactory<AuthController>(() => AuthController(
  authService: sl(),
));
```

## 진행 상태
1. API 응답 모델 정의 [Done] ✅
2. 구글 OAuth2 플로우 구현 [Done] ✅
3. 공통 인프라 모듈 생성 [Done] ✅
4. Repository 구현체 업데이트 [Pending]
5. Service Layer 구현 [Pending]
6. Controller 업데이트 [Pending]
7. 구글 로그인 버튼 활성화 [Pending]
8. 토큰 저장 서비스 구현 [Done] ✅
9. 기본 동작 테스트 [Pending]
10. 에러 처리 공통화 [Pending]
11. DI 컨테이너 업데이트 [Pending]

## 제안된 다음 작업
- 카카오 로그인 API 연동
- 애플 로그인 API 연동
- 이메일 로그인/회원가입 구현
- 토큰 갱신 로직 구현
- 자동 로그인 기능 구현
