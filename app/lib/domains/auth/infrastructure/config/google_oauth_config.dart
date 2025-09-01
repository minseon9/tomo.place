import '../../../../shared/config/env_config.dart';

/// Google OAuth 설정
/// 
/// Google 소셜 로그인에 필요한 모든 설정을 관리합니다.
/// 환경별 설정은 .env 파일에서 로드됩니다.
class GoogleOAuthConfig {
  /// Google OAuth 기본 URL
  static const String baseUrl = 'https://accounts.google.com';
  
  /// 인증 엔드포인트
  static const String authEndpoint = '/o/oauth2/v2/auth';
  
  /// 토큰 엔드포인트
  static const String tokenEndpoint = '/o/oauth2/token';
  
  /// 기본 스코프
  static const String defaultScope = 'email profile';
  
  /// Client ID (환경별 .env에서 로드)
  static String get clientId => EnvConfig.googleClientId;
  
  /// Server Client ID (환경별 .env에서 로드)
  static String get serverClientId => EnvConfig.googleServerClientId;
  
  /// 리다이렉트 URI (환경별 .env에서 로드)
  static String get redirectUri => EnvConfig.googleRedirectUri;
  
  /// 기본 설정 객체 생성
  static OAuthProviderConfig get defaultConfig => OAuthProviderConfig(
    providerId: 'GOOGLE',
    clientId: clientId,
    serverClientId: serverClientId,
    baseUrl: baseUrl,
    authEndpoint: authEndpoint,
    tokenEndpoint: tokenEndpoint,
    scope: defaultScope,
    redirectUri: redirectUri,
  );
}

/// OAuth Provider 설정 공통 모델
class OAuthProviderConfig {
  final String providerId;
  final String clientId;
  final String? serverClientId;
  final String baseUrl;
  final String authEndpoint;
  final String tokenEndpoint;
  final String scope;
  final String redirectUri;
  
  const OAuthProviderConfig({
    required this.providerId,
    required this.clientId,
    this.serverClientId,
    required this.baseUrl,
    required this.authEndpoint,
    required this.tokenEndpoint,
    required this.scope,
    required this.redirectUri,
  });
  
  /// 전체 인증 URL 생성
  String buildAuthUrl({String? state}) {
    final params = <String, String>{
      'response_type': 'code',
      'client_id': clientId,
      'scope': scope,
      'redirect_uri': redirectUri,
    };
    
    if (state != null) {
      params['state'] = state;
    }
    
    // Google 특화 파라미터
    if (providerId == 'GOOGLE') {
      params['access_type'] = 'offline';
      params['prompt'] = 'consent';
    }
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '$baseUrl$authEndpoint?$queryString';
  }
  
  /// 토큰 엔드포인트 전체 URL
  String get tokenUrl => '$baseUrl$tokenEndpoint';
}
