import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/shared/infrastructure/storage/token_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('TokenStorageService Tests', () {
    late TokenStorageService tokenStorage;

    setUp(() {
      tokenStorage = TokenStorageService();
    });

    tearDown(() async {
      // 각 테스트 후에 저장된 토큰들 정리
      await tokenStorage.clearTokens();
    });

    test('should save and retrieve access token', () async {
      const testToken = 'test-access-token-123';
      
      await tokenStorage.saveTokens(
        accessToken: testToken,
        refreshToken: 'refresh-token',
      );
      final retrievedToken = await tokenStorage.getAccessToken();
      
      expect(retrievedToken, equals(testToken));
    });

    test('should save and retrieve refresh token', () async {
      const testRefreshToken = 'test-refresh-token-456';
      
      await tokenStorage.saveTokens(
        accessToken: 'access-token',
        refreshToken: testRefreshToken,
      );
      final retrievedToken = await tokenStorage.getRefreshToken();
      
      expect(retrievedToken, equals(testRefreshToken));
    });

    test('should return null for non-existent access token', () async {
      final token = await tokenStorage.getAccessToken();
      expect(token, isNull);
    });

    test('should return null for non-existent refresh token', () async {
      final token = await tokenStorage.getRefreshToken();
      expect(token, isNull);
    });

    test('should clear all tokens', () async {
      await tokenStorage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
      
      await tokenStorage.clearTokens();
      
      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();
      
      expect(accessToken, isNull);
      expect(refreshToken, isNull);
    });

    test('should return false when no tokens exist', () async {
      final isValid = await tokenStorage.isTokenValid();
      expect(isValid, isFalse);
    });

    test('should return true when access token exists', () async {
      await tokenStorage.saveTokens(
        accessToken: 'valid-token',
        refreshToken: 'refresh-token',
      );
      
      final isValid = await tokenStorage.isTokenValid();
      expect(isValid, isTrue);
    });

    test('should handle empty tokens gracefully', () async {
      await tokenStorage.saveTokens(
        accessToken: '',
        refreshToken: '',
      );
      
      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();
      final isValid = await tokenStorage.isTokenValid();
      
      expect(accessToken, equals(''));
      expect(refreshToken, equals(''));
      expect(isValid, isTrue); // 빈 문자열도 토큰으로 간주
    });

    test('should handle special characters in tokens', () async {
      const specialToken = 'token.with.dots-and-dashes_123!@#';
      const specialRefreshToken = 'refresh.token.with.special.chars!@#\$%^&*()';
      
      await tokenStorage.saveTokens(
        accessToken: specialToken,
        refreshToken: specialRefreshToken,
      );
      
      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();
      
      expect(accessToken, equals(specialToken));
      expect(refreshToken, equals(specialRefreshToken));
    });

    test('should handle very long tokens', () async {
      final longToken = 'a' * 1000; // 1000자 토큰
      final longRefreshToken = 'b' * 1000;
      
      await tokenStorage.saveTokens(
        accessToken: longToken,
        refreshToken: longRefreshToken,
      );
      
      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();
      
      expect(accessToken, equals(longToken));
      expect(refreshToken, equals(longRefreshToken));
    });

    test('should overwrite existing tokens', () async {
      await tokenStorage.saveTokens(
        accessToken: 'old-access',
        refreshToken: 'old-refresh',
      );
      await tokenStorage.saveTokens(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
      );
      
      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();
      
      expect(accessToken, equals('new-access'));
      expect(refreshToken, equals('new-refresh'));
    });
  });
}
