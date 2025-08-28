import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/shared/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    setUp(() async {
      // 각 테스트 전에 SharedPreferences 초기화
      SharedPreferences.setMockInitialValues({});
      await AppConfig.initialize();
    });

    tearDown(() async {
      // 각 테스트 후에 SharedPreferences 정리
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should initialize with default values', () {
      expect(AppConfig.apiUrl, equals('http://127.0.0.1:8080'));
      expect(AppConfig.oauthClientId, equals('1016804314663-ji2taqsu14c3sqfg0u60jfni9shg3dja.apps.googleusercontent.com'));
      expect(AppConfig.oauthRedirectUri, equals('http://localhost:8080/api/auth/social-login'));
    });

    test('should update configuration', () async {
      const newApiUrl = 'https://api.example.com';
      const newClientId = 'new-client-id';
      const newRedirectUri = 'https://app.example.com/callback';
      
      await AppConfig.updateConfig(
        apiUrl: newApiUrl,
        oauthClientId: newClientId,
        oauthRedirectUri: newRedirectUri,
      );
      
      expect(AppConfig.apiUrl, equals(newApiUrl));
      expect(AppConfig.oauthClientId, equals(newClientId));
      expect(AppConfig.oauthRedirectUri, equals(newRedirectUri));
    });

    test('should handle empty local storage gracefully', () async {
      // SharedPreferences를 비우고 다시 로드
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      await AppConfig.initialize();
      
      // 기본값이 유지되어야 함
      expect(AppConfig.apiUrl, equals('http://127.0.0.1:8080'));
      expect(AppConfig.oauthRedirectUri, equals('http://localhost:8080/api/auth/social-login'));
    });

    test('should handle invalid JSON in local storage', () async {
      // 잘못된 JSON 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_config', 'invalid json');
      
      await AppConfig.initialize();
      
      // 기본값이 유지되어야 함
      expect(AppConfig.apiUrl, equals('http://127.0.0.1:8080'));
    });
  });
}
