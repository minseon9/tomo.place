import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/infrastructure/storage/providers.dart';
import 'auth_storage_data_source.dart';

final authStorageDataSourceProvider = Provider<AuthStorageDataSource>(
  (ref) => AuthStorageDataSource(
    memoryStore: ref.read(accessTokenMemoryStoreProvider),
    tokenStorage: ref.read(tokenStorageServiceProvider),
  ),
);
