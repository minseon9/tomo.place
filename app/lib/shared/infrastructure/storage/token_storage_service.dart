import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const String _refreshTokenKey = 'refresh_token';
  static const String _refreshTokenExpiryKey = 'refresh_token_expiry';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

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

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<DateTime?> getRefreshTokenExpiry() async {
    final expiryString = await _storage.read(key: _refreshTokenExpiryKey);
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _refreshTokenExpiryKey),
    ]);
  }
}
