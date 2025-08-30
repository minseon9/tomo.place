import 'package:app/domains/auth/consts/social_provider.dart';

import 'oauth_provider.dart';
import 'google_auth_provider.dart';

class OAuthProviderRegistry {
  static bool _isInitialized = false;
  static final Map<String, OAuthProvider Function()> _providers = {};
  
  static void initialize() {
    if (_isInitialized) {
      return;
    }
    
    _registerGoogleProvider();

    // TODO: Apple Auth Provider 등록 (iOS에서만)
    // _registerAppleProvider();
    // TODO: Kakao Auth Provider 등록
    // _registerKakaoProvider();
    
    _isInitialized = true;
  }
  
  static void registerProvider(String providerId, OAuthProvider Function() factory) {
    _providers[providerId] = factory;
  }
  
  static OAuthProvider createProvider(String providerId) {
    final factory = _providers[providerId];
    if (factory == null) {
      throw ArgumentError('지원하지 않는 Provider: $providerId');
    }
    
    final provider = factory();
    if (!provider.isSupported) {
      throw ArgumentError('Provider $providerId는 현재 플랫폼에서 지원되지 않습니다.');
    }
    
    return provider;
  }
  
  static void _registerGoogleProvider() {
      registerProvider(SocialProvider.google.code, () => GoogleAuthProvider());
  }
  
  /// Apple Auth Provider 등록 (iOS에서만)
  /// 
  /// TODO: Apple Sign-In 구현 시 활성화
  static void _registerAppleProvider() {
    // TODO: Apple Sign-In Provider 구현 후 등록
    // try {
    //   registerProvider('apple', () => AppleAuthProvider());
    //   print('Apple Auth Provider 등록 완료');
    // } catch (e) {
    //   print('Apple Auth Provider 등록 실패: $e');
    // }
  }
  
  /// Kakao Auth Provider 등록
  /// 
  /// TODO: Kakao SDK 구현 시 활성화
  static void _registerKakaoProvider() {
    // TODO: Kakao Auth Provider 구현 후 등록
    // try {
    //   registerProvider('kakao', () => KakaoAuthProvider());
    //   print('Kakao Auth Provider 등록 완료');
    // } catch (e) {
    //   print('Kakao Auth Provider 등록 실패: $e');
    // }
  }
  
  /// 초기화 상태 확인
  static bool get isInitialized => _isInitialized;
}
