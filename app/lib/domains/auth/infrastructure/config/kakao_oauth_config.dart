import 'google_oauth_config.dart'; // OAuthProviderConfig 모델 사용
import '../../../../shared/config/env_config.dart';

/// Kakao OAuth 설정
/// 
/// 카카오 소셜 로그인에 필요한 모든 설정을 관리합니다.
/// 환경별 설정은 .env 파일에서 로드됩니다.
class KakaoOAuthConfig {
  /// Kakao OAuth 기본 URL
  static const String baseUrl = 'https://kauth.kakao.com';
  
  /// 인증 엔드포인트
  static const String authEndpoint = '/oauth/authorize';
  
  /// 토큰 엔드포인트
  static const String tokenEndpoint = '/oauth/token';
  
  /// 기본 스코프
  static const String defaultScope = 'profile_nickname profile_image account_email';
  
  /// Client ID (환경별 .env에서 로드)
  static String get clientId => EnvConfig.kakaoClientId;
  
  /// JavaScript 키 (환경별 .env에서 로드)
  static String get javascriptKey => EnvConfig.kakaoJavascriptKey;
  
  /// 리다이렉트 URI (환경별 .env에서 로드)
  static String get redirectUri => EnvConfig.kakaoRedirectUri;
  
  /// 기본 설정 객체 생성
  static OAuthProviderConfig get defaultConfig => OAuthProviderConfig(
    providerId: 'KAKAO',
    clientId: clientId,
    baseUrl: baseUrl,
    authEndpoint: authEndpoint,
    tokenEndpoint: tokenEndpoint,
    scope: defaultScope,
    redirectUri: redirectUri,
  );
}
