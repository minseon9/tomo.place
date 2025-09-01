/// Figma Spacing System에서 추출한 간격 토큰
/// 
/// 디자인 토큰을 기반으로 한 일관된 간격 시스템입니다.
class AppSpacing {
  AppSpacing._();

  /// Figma 변수와 일치하는 간격
  static const double xs = 4.0; // Spacing-4
  static const double sm = 8.0; // Spacing-8
  static const double md = 16.0; // Spacing-16
  static const double lg = 24.0; // Spacing-24
  static const double xl = 32.0; // Spacing-32
  
  // 기존 값들 유지
  static const double screenPadding = 24.0;
  static const double buttonGap = 12.0;
}
