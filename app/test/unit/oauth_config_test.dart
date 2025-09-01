import 'package:flutter_test/flutter_test.dart';
import 'package:app/shared/config/oauth_config.dart';
import 'package:app/shared/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OAuthConfig Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppConfig.initialize();
    });

    tearDown(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should get Google provider config', () {
      final config = OAuthConfig.getProviderConfig('GOOGLE');
      
      expect(config, isNotNull);
      expect(config?.clientId, isNotEmpty);
      expect(config?.authEndpoint, equals('/o/oauth2/v2/auth'));
      expect(config?.scope, equals('openid email'));
      expect(config?.accessType, equals('offline'));
    });

    test('should get Kakao provider config', () {
      final config = OAuthConfig.getProviderConfig('KAKAO');
      
      expect(config, isNotNull);
      expect(config?.clientId, isNotEmpty);
      expect(config?.authEndpoint, equals('/oauth/authorize'));
      expect(config?.scope, equals('profile_nickname profile_image account_email'));
      expect(config?.accessType, equals('offline'));
    });

    test('should get Apple provider config', () {
      final config = OAuthConfig.getProviderConfig('APPLE');
      
      expect(config, isNotNull);
      expect(config?.clientId, isNotEmpty);
      expect(config?.authEndpoint, equals('/auth/authorize'));
      expect(config?.scope, equals('name email'));
      expect(config?.accessType, equals('offline'));
    });

    test('should return null for unknown provider', () {
      final config = OAuthConfig.getProviderConfig('UNKNOWN');
      expect(config, isNull);
    });

    test('should build auth URL for Google', () {
      const state = 'test-state-123';
      
      final config = OAuthConfig.getProviderConfig('GOOGLE');
      final url = config?.buildAuthUrl(state);
      
      expect(url, isNotNull);
      expect(url, contains('https://accounts.google.com/o/oauth2/v2/auth'));
      expect(url, contains('response_type=code'));
      expect(url, contains('scope=openid%20email'));
      expect(url, contains('state=$state'));
      expect(url, contains('access_type=offline'));
    });

    test('should build auth URL for Kakao', () {
      const state = 'test-state-123';
      
      final config = OAuthConfig.getProviderConfig('KAKAO');
      final url = config?.buildAuthUrl(state);
      
      expect(url, isNotNull);
      expect(url, contains('https://accounts.google.com/oauth/authorize'));
      expect(url, contains('response_type=code'));
      expect(url, contains('scope=profile_nickname%20profile_image%20account_email'));
      expect(url, contains('state=$state'));
      expect(url, contains('access_type=offline'));
    });

    test('should build auth URL for Apple', () {
      const state = 'test-state-123';
      
      final config = OAuthConfig.getProviderConfig('APPLE');
      final url = config?.buildAuthUrl(state);
      
      expect(url, isNotNull);
      expect(url, contains('https://accounts.google.com/auth/authorize'));
      expect(url, contains('response_type=code'));
      expect(url, contains('scope=name%20email'));
      expect(url, contains('state=$state'));
      expect(url, contains('access_type=offline'));
    });

    test('should return null for unknown provider', () {
      final config = OAuthConfig.getProviderConfig('UNKNOWN');
      expect(config, isNull);
    });

    test('should get redirect URI from AppConfig', () {
      final redirectUri = OAuthConfig.redirectUri;
      expect(redirectUri, equals(AppConfig.oauthRedirectUri));
    });

    test('should handle URL encoding correctly', () {
      const state = 'test state with spaces';
      
      final config = OAuthConfig.getProviderConfig('GOOGLE');
      final url = config?.buildAuthUrl(state);
      
      expect(url, contains('state=${Uri.encodeComponent(state)}'));
    });
  });
}
