import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorageInterface {
  Future<void> saveRefreshToken({
    required String refreshToken,
    required DateTime refreshTokenExpiresAt,
  });

  Future<String?> getRefreshToken();

  Future<DateTime?> getRefreshTokenExpiry();

  Future<void> clearTokens();
}

class TokenStorageService implements TokenStorageInterface {
  static const String _refreshTokenKey = 'refresh_token';
  static const String _refreshTokenExpiryKey = 'refresh_token_expiry';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<void> saveRefreshToken({
    required String refreshToken,
    required DateTime refreshTokenExpiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(
        key: _refreshTokenExpiryKey,
        value: refreshTokenExpiresAt.toIso8601String(),
      ),
    ]);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<DateTime?> getRefreshTokenExpiry() async {
    final expiryString = await _storage.read(key: _refreshTokenExpiryKey);
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _refreshTokenExpiryKey),
    ]);
  }
}
