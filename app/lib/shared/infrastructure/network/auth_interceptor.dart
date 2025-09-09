import 'package:tomo_place/shared/infrastructure/ports/auth_token_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domains/auth/core/infra/auth_domain_adapter_provider.dart';
import '../ports/auth_domain_port.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authService);

  final AuthDomainPort _authService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    AuthTokenDto? authToken = await _authService.getValidToken();

    if (authToken == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {'message': 'Authentication required'},
          ),
        ),
        true,
      );
      return;
    }

    options.headers['Authorization'] = authToken.authorizationHeader;
    handler.next(options);
  }
}

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(ref.read(authDomainAdapterProvider));
});
