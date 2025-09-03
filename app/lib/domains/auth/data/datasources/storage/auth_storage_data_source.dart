import '../../../../../../shared/infrastructure/storage/access_token_memory_store.dart';
import '../../../../../../shared/infrastructure/storage/token_storage_service.dart';
import '../../../core/entities/auth_token.dart';

abstract class AuthStorageDataSource {
  Future<AuthToken?> getCurrentToken();

  Future<void> saveToken(AuthToken token);

  Future<void> clearToken();
}

class AuthStorageDataSourceImpl implements AuthStorageDataSource {
  final AccessTokenMemoryStore _memoryStore;
  final TokenStorageService _tokenStorage;

  AuthStorageDataSourceImpl({
    required AccessTokenMemoryStore memoryStore,
    required TokenStorageService tokenStorage,
  }) : _memoryStore = memoryStore,
       _tokenStorage = tokenStorage;

  @override
  Future<AuthToken?> getCurrentToken() async {
    try {
      final accessToken = _memoryStore.token;
      final accessTokenExpiresAt = _memoryStore.expiresAt;
      final refreshToken = await _tokenStorage.getRefreshToken();
      final refreshTokenExpiresAt = await _tokenStorage.getRefreshTokenExpiry();

      if (accessToken == null ||
          refreshToken == null ||
          accessTokenExpiresAt == null ||
          refreshTokenExpiresAt == null) {
        return null;
      }

      return AuthToken(
        accessToken: accessToken,
        accessTokenExpiresAt: accessTokenExpiresAt,
        refreshToken: refreshToken,
        refreshTokenExpiresAt: refreshTokenExpiresAt,
        tokenType: 'Bearer',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveToken(AuthToken token) async {
    await _tokenStorage.saveRefreshToken(
      refreshToken: token.refreshToken,
      refreshTokenExpiresAt: token.refreshTokenExpiresAt,
    );
    _memoryStore.set(token.accessToken, token.accessTokenExpiresAt);
  }

  @override
  Future<void> clearToken() async {
    await _tokenStorage.clearTokens();
    _memoryStore.clear();
  }
}
