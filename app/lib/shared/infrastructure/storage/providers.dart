import 'package:app/shared/infrastructure/storage/access_token_memory_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_storage_service.dart';

final accessTokenMemoryStoreProvider =
    Provider<AccessTokenMemoryStoreInterface>(
      (ref) => AccessTokenMemoryStore(),
    );

// Storage Providers
final tokenStorageServiceProvider = Provider<TokenStorageInterface>(
  (ref) => TokenStorageService(),
);
