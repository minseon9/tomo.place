import 'package:tomo_place/shared/infrastructure/network/base_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthClient extends BaseClient {
  /// Authorization이 필요하지 않은 request를 처리하는 Client
  ///  /api/auth/signup
  ///  /api/auth/refresh
  AuthClient() : super(List.empty());
}

final authClientProvider = Provider<BaseClient>((ref) {
  return AuthClient();
});
