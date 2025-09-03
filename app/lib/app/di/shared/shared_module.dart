import 'package:get_it/get_it.dart';

import '../../../domains/auth/core/usecases/startup_refresh_token_usecase.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/infrastructure/network/api_client.dart';
import '../../../shared/infrastructure/network/auth_interceptor.dart';
import '../../../shared/infrastructure/storage/access_token_memory_store.dart';
import '../../../shared/infrastructure/storage/token_storage_service.dart';

class SharedModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<AppConfig>(() => AppConfig());

    sl.registerLazySingleton<AccessTokenMemoryStore>(
      () => AccessTokenMemoryStore(),
    );

    sl.registerLazySingleton<ApiClient>(() {
      final client = ApiClient();
      client.addInterceptor(
        AuthInterceptor(
          sl<AccessTokenMemoryStore>(),
          sl<StartupRefreshTokenUseCase>(),
        ),
      );
      return client;
    });

    sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());
  }
}
