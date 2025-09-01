import '../../core/entities/social_provider.dart';
import 'google_oauth_config.dart';
import 'apple_oauth_config.dart';
import 'kakao_oauth_config.dart';

/// OAuth 설정 통합 관리 클래스
/// 
/// 각 Provider별 설정을 중앙에서 관리하고 제공합니다.
/// Auth 도메인 내에서만 사용되는 전용 설정 관리자입니다.
class OAuthConfig {
  /// Provider별 설정 팩토리
  static final Map<String, OAuthProviderConfig> _providerConfigs = {
    SocialProvider.google.code: GoogleOAuthConfig.defaultConfig,
    SocialProvider.apple.code: AppleOAuthConfig.defaultConfig,
    SocialProvider.kakao.code: KakaoOAuthConfig.defaultConfig,
  };
  
  /// Provider 설정 조회
  /// 
  /// [provider] SocialProvider enum 또는 문자열
  /// Returns: 해당 Provider의 OAuth 설정, 없으면 null
  static OAuthProviderConfig? getProviderConfig(String provider) {
    return _providerConfigs[provider.toUpperCase()];
  }
  
  /// SocialProvider enum으로 설정 조회
  static OAuthProviderConfig? getConfigByProvider(SocialProvider provider) {
    return getProviderConfig(provider.code);
  }
  
  /// 지원하는 모든 Provider 목록
  static List<String> get supportedProviders => _providerConfigs.keys.toList();
  
  /// Provider가 지원되는지 확인
  static bool isProviderSupported(String provider) {
    return _providerConfigs.containsKey(provider.toUpperCase());
  }
  
  /// Google 전용 설정 (편의 메서드)
  static OAuthProviderConfig get googleConfig => GoogleOAuthConfig.defaultConfig;
  
  /// Apple 전용 설정 (편의 메서드)
  static OAuthProviderConfig get appleConfig => AppleOAuthConfig.defaultConfig;
  
  /// Kakao 전용 설정 (편의 메서드)
  static OAuthProviderConfig get kakaoConfig => KakaoOAuthConfig.defaultConfig;
  
  /// 환경별 설정 업데이트 (개발/스테이징/프로덕션)
  /// 
  /// 런타임에 설정을 동적으로 변경할 수 있습니다.
  static void updateProviderConfig(String provider, OAuthProviderConfig config) {
    _providerConfigs[provider.toUpperCase()] = config;
  }
  
  /// 설정 새로고침
  /// 
  /// .env 파일이 변경되었을 때 Provider 설정들을 다시 로드합니다.
  static void refreshConfigs() {
    _providerConfigs['GOOGLE'] = GoogleOAuthConfig.defaultConfig;
    _providerConfigs['APPLE'] = AppleOAuthConfig.defaultConfig;
    _providerConfigs['KAKAO'] = KakaoOAuthConfig.defaultConfig;
  }
}
