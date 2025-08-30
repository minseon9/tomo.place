import 'oauth_models.dart';

/// OAuth Provider 추상 클래스
/// 
/// 모든 OAuth Provider가 구현해야 하는 공통 인터페이스를 정의합니다.
/// 각 Provider별로 이 인터페이스를 구현하여 일관된 API를 제공합니다.
abstract class OAuthProvider {
  /// Provider 식별자
  /// 
  /// 예: 'google', 'apple', 'kakao'
  String get providerId;
  
  /// Provider 표시 이름
  /// 
  /// 예: 'Google', 'Apple', 'Kakao'
  String get displayName;
  
  /// Provider가 현재 플랫폼에서 지원되는지 확인
  bool get isSupported;
  
  /// 로그인 실행
  /// 
  /// OAuth 인증 플로우를 시작하고 결과를 반환합니다.
  /// 
  /// Returns:
  /// - OAuthResult.success: 로그인 성공 시
  /// - OAuthResult.failure: 로그인 실패 시
  Future<OAuthResult> signIn();
  
  /// 로그아웃 실행
  /// 
  /// 현재 로그인된 사용자를 로그아웃시킵니다.
  Future<void> signOut();
  
  /// Provider와의 연결을 완전히 해제합니다.
  /// 로그아웃과 달리 계정 연결 자체를 해제합니다.
  Future<void> disconnect();
  
  /// Provider 사용 전 필요한 초기화 작업을 수행합니다.
  /// 대부분의 Provider는 자동으로 초기화되므로 기본 구현은 빈 메서드입니다.
  Future<void> initialize() async {
    // 기본 구현: 아무것도 하지 않음
  }
  
  /// Provider 정리
  /// 
  /// Provider 사용 후 필요한 정리 작업을 수행합니다.
  /// 대부분의 Provider는 자동으로 정리되므로 기본 구현은 빈 메서드입니다.
  Future<void> dispose() async {
    // 기본 구현: 아무것도 하지 않음
  }
}

/// OAuth Provider Factory
/// 
/// Provider ID에 따라 적절한 OAuthProvider 인스턴스를 생성합니다.
class OAuthProviderFactory {
  static final Map<String, OAuthProvider Function()> _providers = {};
  
  /// Provider 등록
  /// 
  /// 새로운 Provider를 Factory에 등록합니다.
  static void registerProvider(String providerId, OAuthProvider Function() factory) {
    _providers[providerId] = factory;
  }
  
  /// Provider 생성
  /// 
  /// Provider ID에 따라 적절한 OAuthProvider 인스턴스를 생성합니다.
  /// 
  /// Throws:
  /// - ArgumentError: 지원하지 않는 Provider ID인 경우
  static OAuthProvider createProvider(String providerId) {
    final factory = _providers[providerId];
    if (factory == null) {
      throw ArgumentError('지원하지 않는 Provider: $providerId');
    }
    
    final provider = factory();
    
    // Provider가 현재 플랫폼에서 지원되지 않는 경우
    if (!provider.isSupported) {
      throw ArgumentError('Provider $providerId는 현재 플랫폼에서 지원되지 않습니다.');
    }
    
    return provider;
  }
  
  /// 지원하는 Provider 목록 조회
  /// 
  /// 현재 플랫폼에서 지원하는 Provider 목록을 반환합니다.
  static List<String> getSupportedProviders() {
    return _providers.keys.where((providerId) {
      try {
        final provider = createProvider(providerId);
        return provider.isSupported;
      } catch (e) {
        return false;
      }
    }).toList();
  }
  
  /// Provider 존재 여부 확인
  /// 
  /// 특정 Provider가 등록되어 있는지 확인합니다.
  static bool isProviderRegistered(String providerId) {
    return _providers.containsKey(providerId);
  }
  
  /// 모든 등록된 Provider 목록 조회
  /// 
  /// 등록된 모든 Provider 목록을 반환합니다 (플랫폼 지원 여부와 관계없이).
  static List<String> getAllRegisteredProviders() {
    return _providers.keys.toList();
  }
}
