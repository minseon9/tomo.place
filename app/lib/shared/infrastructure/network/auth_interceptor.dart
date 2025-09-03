import 'package:dio/dio.dart';

import '../../../app/services/navigation_service.dart';
import '../../../domains/auth/core/usecases/startup_refresh_token_usecase.dart';
import '../../services/graceful_logout_handler.dart';
import '../storage/access_token_memory_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._memoryStore, this._refreshUseCase);

  final AccessTokenMemoryStore _memoryStore;
  final StartupRefreshTokenUseCase _refreshUseCase;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final result = await _refreshUseCase.execute();

    if (!result.isAuthenticated()) {
      GracefulLogoutHandler.handle(customMessage: '다시 로그인해주세요.');
      NavigationService.navigateToSignup();

      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 401,
          data: {'message': "${result.message}"},
        ),
      );

      return;
    }

    final currentToken = _memoryStore.token;
    if (currentToken != null) {
      options.headers['Authorization'] = 'Bearer $currentToken';
    }

    handler.next(options);
  }
}
