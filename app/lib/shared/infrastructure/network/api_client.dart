import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_interceptor.dart';
import 'base_client.dart';

class ApiClient extends BaseClient {
  /// Authorization을 필수로 하는 request를 처리하는 Client
  /// /api/auth/signup, /api/auth/refresh 를 제외한 모든 API는 해당 client를 사용

  ApiClient(AuthInterceptor authInterceptor) : super([authInterceptor]);
}

// Network Providers

final apiClientProvider = Provider<BaseClient>((ref) {
  final authInterceptor = ref.read(authInterceptorProvider);
  return ApiClient(authInterceptor);
});
