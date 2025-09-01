import 'package:get_it/get_it.dart';

// Shared infrastructure imports
import '../../shared/infrastructure/network/api_client.dart';
import '../../shared/infrastructure/storage/token_storage_service.dart';
import '../../shared/config/app_config.dart';

// Core layer imports (Domain)
import '../../domains/auth/core/repositories/auth_repository.dart';
import '../../domains/auth/core/usecases/login_with_social_usecase.dart';
import '../../domains/auth/core/usecases/logout_usecase.dart';
import '../../domains/auth/core/usecases/refresh_token_usecase.dart';
import '../../domains/auth/core/usecases/check_auth_status_usecase.dart';

// Infrastructure layer imports
import '../../domains/auth/infrastructure/repositories/auth_repository_impl.dart';

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
/// Clean Architecture에 따른 등록 순서: Shared Infrastructure → Infrastructure → Core → Presentation
Future<void> initializeDependencies() async {
  // ===== Shared Infrastructure =====
  // 앱 설정 초기화
  await AppConfig.initialize();
  
  // 공통 인프라 서비스
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());
  
  // ===== Infrastructure Layer =====
  // Repository 구현체들
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  
  // ===== Core Layer (UseCases) =====
  // 각 UseCase들은 필요한 의존성을 주입받아 등록
  sl.registerLazySingleton<LoginWithSocialUseCase>(() => LoginWithSocialUseCase(
    repository: sl(),
    tokenStorage: sl(),
  ));
  
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(
    repository: sl(),
    tokenStorage: sl(),
  ));
  
  sl.registerLazySingleton<RefreshTokenUseCase>(() => RefreshTokenUseCase(
    repository: sl(),
    tokenStorage: sl(),
  ));
  
  sl.registerLazySingleton<CheckAuthStatusUseCase>(() => CheckAuthStatusUseCase(
    tokenStorage: sl(),
  ));
  
  // ===== Presentation Layer =====
  // Controller는 UseCase들을 주입받아 등록
  sl.registerFactory<AuthController>(() => AuthController(
    loginWithSocialUseCase: sl(),
    logoutUseCase: sl(),
  ));
}
