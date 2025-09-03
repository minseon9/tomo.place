import 'package:get_it/get_it.dart';

import '../../../../domains/auth/core/repositories/auth_repository.dart';
import '../../../../domains/auth/core/repositories/auth_token_repository.dart';
import '../../../../domains/auth/core/usecases/check_auth_status_usecase.dart';
import '../../../../domains/auth/core/usecases/check_refresh_token_status_usecase.dart';
import '../../../../domains/auth/core/usecases/logout_usecase.dart';
import '../../../../domains/auth/core/usecases/signup_with_social_usecase.dart';
import '../../../../domains/auth/core/usecases/startup_refresh_token_usecase.dart';
import '../../../../domains/auth/data/datasources/api/auth_api_data_source.dart';
import '../../../../domains/auth/data/datasources/storage/auth_storage_data_source.dart';
import '../../../../domains/auth/data/repositories/auth_repository_impl.dart';
import '../../../../domains/auth/data/repositories/auth_token_repository_impl.dart';
import '../../../../domains/auth/presentation/controllers/auth_controller.dart';
import '../../../../shared/services/error_reporter.dart';

class AuthModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<AuthApiDataSource>(
      () => AuthApiDataSourceImpl(sl()),
    );

    sl.registerLazySingleton<AuthStorageDataSource>(
      () => AuthStorageDataSourceImpl(memoryStore: sl(), tokenStorage: sl()),
    );

    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
    sl.registerLazySingleton<AuthTokenRepository>(
      () => AuthTokenRepositoryImpl(sl()),
    );

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

    sl.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(repository: sl(), tokenStorage: sl()),
    );

    sl.registerFactory<AuthController>(
      () => AuthController(
        loginWithSocialUseCase: sl(),
        logoutUseCase: sl(),
        errorReporter: sl<ErrorReporter>(),
      ),
    );
  }
}
