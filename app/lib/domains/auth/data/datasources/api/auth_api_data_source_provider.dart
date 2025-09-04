import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/infrastructure/network/auth_client.dart';
import 'auth_api_data_source.dart';

final authApiDataSourceProvider = Provider<AuthApiDataSource>((ref) {
  final client = ref.read(authClientProvider);
  return AuthApiDataSourceImpl(client);
});
