import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/domains/auth/data/oauth/config/kakao_oauth_config.dart';
import 'package:tomo_place/shared/config/env_config.dart';
import 'package:tomo_place/domains/auth/consts/social_provider.dart';

// Mock EnvConfigInterface
class MockEnvConfigInterface extends Mock implements EnvConfigInterface {}

void main() {
  group('KakaoOAuthConfig', () {
    late MockEnvConfigInterface mockEnvConfig;
    late KakaoOAuthConfig config;

    setUp(() {
      mockEnvConfig = MockEnvConfigInterface();
      when(() => mockEnvConfig.kakaoClientId).thenReturn('test_kakao_client_id');
      when(() => mockEnvConfig.kakaoJavascriptKey).thenReturn('test_javascript_key');
      when(() => mockEnvConfig.kakaoRedirectUri).thenReturn('https://test.com/callback');
      
      config = KakaoOAuthConfig(mockEnvConfig);
    });

    group('기본 속성', () {
      test('providerId는 KAKAO이어야 한다', () {
        expect(config.providerId, equals(SocialProvider.kakao.code));
      });

      test('clientId는 EnvConfig에서 가져온 값이어야 한다', () {
        expect(config.clientId, equals('test_kakao_client_id'));
      });

      test('javascriptKey는 EnvConfig에서 가져온 값이어야 한다', () {
        expect(config.javascriptKey, equals('test_javascript_key'));
      });

      test('redirectUri는 EnvConfig에서 가져온 값이어야 한다', () {
        expect(config.redirectUri, equals('https://test.com/callback'));
      });

      test('baseUrl은 Kakao OAuth URL이어야 한다', () {
        expect(config.baseUrl, equals('https://kauth.kakao.com'));
      });

      test('authEndpoint는 올바른 경로여야 한다', () {
        expect(config.authEndpoint, equals('/oauth/authorize'));
      });

      test('tokenEndpoint는 올바른 경로여야 한다', () {
        expect(config.tokenEndpoint, equals('/oauth/token'));
      });

      test('scope는 Kakao 권한들을 포함해야 한다', () {
        expect(config.scope, equals(['profile_nickname', 'profile_image', 'account_email']));
      });
    });

    group('Kakao 특화 메서드', () {
      test('tokenUrl은 baseUrl과 tokenEndpoint를 조합한 값이어야 한다', () {
        expect(config.tokenUrl, equals('https://kauth.kakao.com/oauth/token'));
      });

      test('authUrl은 baseUrl과 authEndpoint를 조합한 값이어야 한다', () {
        expect(config.authUrl, equals('https://kauth.kakao.com/oauth/authorize'));
      });
    });

    group('기본값 처리', () {
      test('clientId가 비어있으면 기본값을 사용해야 한다', () {
        // Given
        when(() => mockEnvConfig.kakaoClientId).thenReturn('');
        when(() => mockEnvConfig.kakaoJavascriptKey).thenReturn('');
        when(() => mockEnvConfig.kakaoRedirectUri).thenReturn('');

        // When
        final configWithDefaults = KakaoOAuthConfig(mockEnvConfig);

        // Then
        expect(configWithDefaults.clientId, equals('kakao_client_id'));
        expect(configWithDefaults.javascriptKey, equals(''));
        expect(configWithDefaults.redirectUri, equals('https://example.com/auth/kakao/callback'));
      });
    });

    group('환경 설정 의존성', () {
      test('EnvConfig가 변경되면 값이 업데이트되어야 한다', () {
        // Given
        when(() => mockEnvConfig.kakaoClientId).thenReturn('new_client_id');
        when(() => mockEnvConfig.kakaoJavascriptKey).thenReturn('new_javascript_key');
        when(() => mockEnvConfig.kakaoRedirectUri).thenReturn('https://new.com/callback');

        // When
        final newConfig = KakaoOAuthConfig(mockEnvConfig);

        // Then
        expect(newConfig.clientId, equals('new_client_id'));
        expect(newConfig.javascriptKey, equals('new_javascript_key'));
        expect(newConfig.redirectUri, equals('https://new.com/callback'));
      });
    });
  });
}
