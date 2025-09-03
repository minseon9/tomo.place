import '../../core/entities/auth_token.dart';
import '../../core/repositories/auth_token_repository.dart';
import '../datasources/storage/auth_storage_data_source.dart';

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

  @override
  Future<bool> isTokenValid() async {
    return await _storageDataSource.isTokenValid();
  }

  @override
  Future<String> getTokenStatus() async {
    return await _storageDataSource.getTokenStatus();
  }
}
