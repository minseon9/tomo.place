import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 토큰 저장 서비스
/// 
/// Access Token과 Refresh Token을 안전하게 저장하고 관리합니다.
/// Flutter Secure Storage를 사용하여 암호화된 저장소에 보관합니다.
class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  /// 토큰 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      if (expiresAt != null)
        _storage.write(key: _tokenExpiryKey, value: expiresAt.toIso8601String()),
    ]);
  }
  
  /// Access Token 조회
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
  
  /// Refresh Token 조회
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  /// 토큰 만료 시간 조회
  Future<DateTime?> getTokenExpiry() async {
    final expiryString = await _storage.read(key: _tokenExpiryKey);
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }
  
  /// 토큰이 유효한지 확인
  Future<bool> isTokenValid() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;
    
    final expiry = await getTokenExpiry();
    if (expiry != null && DateTime.now().isAfter(expiry)) {
      return false;
    }
    
    return true;
  }
  
  /// 토큰이 곧 만료될지 확인 (5분 전)
  Future<bool> isTokenAboutToExpire() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return false;
    
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiry);
  }
  
  /// 토큰 삭제 (로그아웃 시)
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _tokenExpiryKey),
    ]);
  }
  
  /// Access Token만 삭제 (갱신 시)
  Future<void> clearAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }
}
