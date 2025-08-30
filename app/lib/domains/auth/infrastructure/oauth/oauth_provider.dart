import '../../../../shared/exceptions/oauth_result.dart';

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
