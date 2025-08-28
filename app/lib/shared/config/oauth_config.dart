import 'app_config.dart';

/// OAuth 설정 관리 클래스
/// 
/// 각 Provider별 OAuth 설정을 중앙에서 관리합니다.
/// AppConfig를 통해 런타임에 설정을 업데이트할 수 있습니다.
class OAuthConfig {
  static const String _baseUrl = 'https://accounts.google.com';
  
  /// Provider별 설정
  static const Map<String, OAuthProviderConfig> _providers = {
          'GOOGLE': OAuthProviderConfig(
        clientId: AppConfig.oauthClientId ?? '1016804314663-ji2taqsu14c3sqfg0u60jfni9shg3dja.apps.googleusercontent.com',
      authEndpoint: '/o/oauth2/v2/auth',
      scope: 'openid email',
      accessType: 'offline',
    ),
    'KAKAO': OAuthProviderConfig(
      clientId: AppConfig.oauthClientId ?? '',
      authEndpoint: '/oauth/authorize',
      scope: 'profile_nickname profile_image account_email',
      accessType: 'offline',
    ),
    'APPLE': OAuthProviderConfig(
      clientId: AppConfig.oauthClientId ?? '',
      authEndpoint: '/auth/authorize',
      scope: 'name email',
      accessType: 'offline',
    ),
  };
  
  /// Provider 설정 조회
  static OAuthProviderConfig? getProviderConfig(String provider) {
    return _providers[provider.toUpperCase()];
  }
  
  /// 기본 URL 조회
  static String get baseUrl => _baseUrl;
  
  /// 리다이렉트 URI 조회
  static String get redirectUri => AppConfig.oauthRedirectUri;
}

/// Provider별 OAuth 설정
class OAuthProviderConfig {
  final String clientId;
  final String authEndpoint;
  final String scope;
  final String accessType;
  
  const OAuthProviderConfig({
    required this.clientId,
    required this.authEndpoint,
    required this.scope,
    required this.accessType,
  });
  
  /// 전체 인증 URL 생성
  String buildAuthUrl(String state) {
    final params = {
      'response_type': 'code',
      'client_id': clientId,
      'scope': scope,
      'redirect_uri': OAuthConfig.redirectUri,
      'state': state,
      'access_type': accessType,
    };
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '${OAuthConfig.baseUrl}$authEndpoint?$queryString';
  }
}
