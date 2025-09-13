/// 앱 전체의 라우트 상수를 중앙 관리하는 클래스
/// 
/// 모든 도메인의 라우트 경로를 한 곳에서 관리하여
/// 라우트 변경 시 일관성을 보장하고 유지보수를 용이하게 합니다.
class Routes {
  Routes._();
  
  // Auth 도메인 라우트
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  
  // Terms Agreement 도메인 라우트
  static const String termsOfService = '/terms/terms-of-service';
  static const String privacyPolicy = '/terms/privacy-policy';
  static const String locationTerms = '/terms/location-terms';
  
  // 공통 라우트
  static const String splash = '/splash';
  static const String home = '/home';
}
