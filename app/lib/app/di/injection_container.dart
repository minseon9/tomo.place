import 'package:get_it/get_it.dart';

// Shared infrastructure imports
import '../../shared/infrastructure/network/api_client.dart';
import '../../shared/infrastructure/storage/token_storage_service.dart';
import '../../shared/infrastructure/external_services/oauth_service.dart';
import '../../shared/config/app_config.dart';

// Domain layer imports
import '../../domains/auth/domain/repositories/auth_repository.dart';

// Data layer imports
import '../../domains/auth/data/repositories/auth_repository_impl.dart';

// Service layer imports
import '../../domains/auth/services/auth_service.dart';

// Presentation layer imports
import '../../domains/auth/presentation/controllers/auth_controller.dart';

/// 의존성 주입 컨테이너
/// 
/// GetIt을 사용하여 앱 전체의 의존성을 관리합니다.
/// Clean Architecture의 의존성 역전 원칙을 구현하는 핵심 요소입니다.
final GetIt sl = GetIt.instance;

/// 의존성 초기화
/// 
/// 앱 시작 시 호출되어 모든 의존성을 등록합니다.
/// 개선된 아키텍처에 따라 등록 순서: Shared Infrastructure → Data → Service → Presentation
Future<void> initializeDependencies() async {
  // ===== Shared Infrastructure =====
  // 앱 설정 초기화
  await AppConfig.initialize();
  
  // 공통 인프라 서비스
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());
  sl.registerLazySingleton<OAuthService>(() => OAuthServiceImpl());
  
  // ===== Data Layer =====
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  
  // ===== Service Layer =====
  sl.registerLazySingleton<AuthService>(() => AuthService(
    repository: sl(),
    tokenStorage: sl(),
    oauthService: sl(),
  ));
  
  // ===== Presentation Layer =====
  sl.registerFactory<AuthController>(() => AuthController(
    authService: sl(),
  ));
}

// Mock 구현체들은 제거 - 실제 구현체 사용
