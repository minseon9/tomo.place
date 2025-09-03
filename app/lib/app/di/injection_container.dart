import 'package:get_it/get_it.dart';

// Core layer imports (Domain)
import '../../domains/auth/core/repositories/auth_repository.dart';
import '../../domains/auth/core/repositories/auth_token_repository.dart';
import '../../domains/auth/core/usecases/check_auth_status_usecase.dart';
// Shared infrastructure imports
import '../../domains/auth/core/usecases/check_refresh_token_status_usecase.dart';
import '../../domains/auth/core/usecases/logout_usecase.dart';
import '../../domains/auth/core/usecases/signup_with_social_usecase.dart';
import '../../domains/auth/core/usecases/startup_refresh_token_usecase.dart';
import '../../domains/auth/data/datasources/api/auth_api_data_source.dart';
import '../../domains/auth/data/datasources/storage/auth_storage_data_source.dart';
// Infrastructure layer imports
import '../../domains/auth/data/repositories/auth_repository_impl.dart';
import '../../domains/auth/data/repositories/auth_token_repository_impl.dart';
// Presentation layer imports
import '../../domains/auth/presentation/controllers/auth_controller.dart';
import '../../shared/config/app_config.dart';
import '../../shared/infrastructure/network/api_client.dart';
import '../../shared/infrastructure/network/auth_interceptor.dart';
import '../../shared/infrastructure/storage/access_token_memory_store.dart';
import '../../shared/infrastructure/storage/token_storage_service.dart';

final GetIt sl = GetIt.instance;

// FIXME: 이 id에서 모든 걸 관리해야하는건지?
Future<void> initializeDependencies() async {
  // ===== Shared Infrastructure =====
  // 앱 설정 초기화
  await AppConfig.initialize();

  // 공통 인프라 서비스
  sl.registerLazySingleton<AccessTokenMemoryStore>(
    () => AccessTokenMemoryStore(),
  );

  sl.registerLazySingleton<ApiClient>(() {
    final client = ApiClient();
    client.addInterceptor(AuthInterceptor(sl()));
    return client;
  });
  sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());

  // ===== Infrastructure Layer =====
  // DataSource들
  sl.registerLazySingleton<AuthApiDataSource>(
    () => AuthApiDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthStorageDataSource>(
    () => AuthStorageDataSourceImpl(memoryStore: sl(), tokenStorage: sl()),
  );

  // Repository 구현체들
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton<AuthTokenRepository>(
    () => AuthTokenRepositoryImpl(sl()),
  );

  // ===== Core Layer (UseCases) =====
  // 각 UseCase들은 필요한 의존성을 주입받아 등록
  sl.registerLazySingleton<SignupWithSocialUseCase>(
    () => SignupWithSocialUseCase(
      repository: sl(),
      tokenStorage: sl(),
      memoryStore: sl(),
    ),
  );

  sl.registerLazySingleton<StartupRefreshTokenUseCase>(
    () => StartupRefreshTokenUseCase(repository: sl(), tokenRepository: sl()),
  );

  sl.registerLazySingleton<CheckRefreshTokenStatusUseCase>(
    () => CheckRefreshTokenStatusUseCase(tokenStorage: sl()),
  );

  sl.registerLazySingleton<CheckAuthStatusUseCase>(
    () => CheckAuthStatusUseCase(authTokenRepository: sl()),
  );

  // ===== Presentation Layer =====
  // Controller는 UseCase들을 주입받아 등록
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: sl(), tokenStorage: sl()),
  );

  sl.registerFactory<AuthController>(
    () => AuthController(loginWithSocialUseCase: sl(), logoutUseCase: sl()),
  );
}
