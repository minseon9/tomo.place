import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/entities/auth_token.dart';
import '../../core/repositories/auth_token_repository.dart';
import '../datasources/storage/auth_storage_data_source.dart';
import '../datasources/storage/auth_storage_data_source_provider.dart';

class AuthTokenRepositoryImpl implements AuthTokenRepository {
  final AuthStorageDataSource _storageDataSource;

  AuthTokenRepositoryImpl(this._storageDataSource);

  @override
  Future<AuthToken?> getCurrentToken() async {
    return await _storageDataSource.getCurrentToken();
  }

  @override
  Future<void> saveToken(AuthToken token) async {
    await _storageDataSource.saveToken(token);
  }

  @override
  Future<void> clearToken() async {
    await _storageDataSource.clearToken();
  }
}

final authTokenRepositoryProvider = Provider<AuthTokenRepository>(
  (ref) => AuthTokenRepositoryImpl(ref.read(authStorageDataSourceProvider)),
);
