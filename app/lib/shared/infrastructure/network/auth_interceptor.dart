import 'package:dio/dio.dart';

import '../../../domains/auth/core/usecases/startup_refresh_token_usecase.dart';
import '../../services/session_event_bus.dart';
import '../storage/access_token_memory_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._memoryStore, this._refreshUseCase, this._eventBus);

  final AccessTokenMemoryStore _memoryStore;
  final StartupRefreshTokenUseCase _refreshUseCase;
  final SessionEventBus _eventBus;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final result = await _refreshUseCase.execute();

    if (!result.isAuthenticated()) {
      _eventBus.publish(SessionEvent.expired);
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {'message': "${result.message}"},
          ),
        ),
        true,
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
