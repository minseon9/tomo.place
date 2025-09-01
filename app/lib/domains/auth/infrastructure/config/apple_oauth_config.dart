import 'google_oauth_config.dart'; // OAuthProviderConfig 모델 사용
import '../../../../shared/config/env_config.dart';

/// Apple OAuth 설정
/// 
/// Apple Sign-In에 필요한 모든 설정을 관리합니다.
/// 환경별 설정은 .env 파일에서 로드됩니다.
class AppleOAuthConfig {
  /// Apple OAuth 기본 URL
  static const String baseUrl = 'https://appleid.apple.com';
  
  /// 인증 엔드포인트
  static const String authEndpoint = '/auth/authorize';
  
  /// 토큰 엔드포인트
  static const String tokenEndpoint = '/auth/token';
  
  /// 기본 스코프
  static const String defaultScope = 'name email';
  
  /// Client ID (환경별 .env에서 로드)
  static String get clientId => EnvConfig.appleClientId;
  
  /// Team ID (환경별 .env에서 로드)
  static String get teamId => EnvConfig.appleTeamId;
  
  /// Key ID (환경별 .env에서 로드)
  static String get keyId => EnvConfig.appleKeyId;
  
  /// 리다이렉트 URI (환경별 .env에서 로드)
  static String get redirectUri => EnvConfig.appleRedirectUri;
  
  /// 기본 설정 객체 생성
  static OAuthProviderConfig get defaultConfig => OAuthProviderConfig(
    providerId: 'APPLE',
    clientId: clientId,
    baseUrl: baseUrl,
    authEndpoint: authEndpoint,
    tokenEndpoint: tokenEndpoint,
    scope: defaultScope,
    redirectUri: redirectUri,
  );
}
