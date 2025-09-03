import '../../../../../../shared/infrastructure/storage/access_token_memory_store.dart';
import '../../../../../../shared/infrastructure/storage/token_storage_service.dart';
import '../../../core/entities/auth_token.dart';

abstract class AuthStorageDataSource {
  Future<AuthToken?> getCurrentToken();

  Future<void> saveToken(AuthToken token);

  Future<void> clearToken();

  Future<bool> isTokenValid();

  Future<String> getTokenStatus();
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
      final refreshToken = await _tokenStorage.getRefreshToken();
      final expiresAt = _memoryStore.expiresAt;

      if (accessToken == null || refreshToken == null || expiresAt == null) {
        return null;
      }

      return AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
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
      refreshTokenExpiresAt: token.expiresAt,
    );
    _memoryStore.set(token.accessToken, token.expiresAt);
  }

  @override
  Future<void> clearToken() async {
    await _tokenStorage.clearTokens();
    _memoryStore.clear();
  }

  @override
  Future<bool> isTokenValid() async {
    final token = await getCurrentToken();
    return token?.isValid ?? false;
  }

  @override
  Future<String> getTokenStatus() async {
    final token = await getCurrentToken();
    return token?.status ?? 'no_token';
  }
}
