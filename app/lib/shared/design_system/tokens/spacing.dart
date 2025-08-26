/// Figma Auto Layout에서 추출한 간격 시스템
/// 
/// 일관된 간격을 위한 디자인 토큰입니다.
class AppSpacing {
  AppSpacing._();

  /// 기본 간격 단위 (4px)
  static const double unit = 4.0;

  /// 간격 상수들 (4px 단위)
  static const double xs = unit * 1;      // 4px
  static const double sm = unit * 2;      // 8px
  static const double md = unit * 3;      // 12px
  static const double lg = unit * 4;      // 16px
  static const double xl = unit * 5;      // 20px
  static const double xxl = unit * 6;     // 24px
  static const double xxxl = unit * 8;    // 32px

  /// 컴포넌트별 특수 간격
  static const double buttonPaddingVertical = 16.0;
  static const double buttonPaddingHorizontal = 24.0;
  static const double cardPadding = 16.0;
  static const double screenPadding = 24.0;
  static const double sectionGap = 32.0;

  /// 버튼 간격
  static const double buttonGap = 12.0; // 버튼 사이 간격
  static const double buttonGroupGap = 16.0; // 그룹 상/하 여백 기본값

  /// 입력 필드 간격
  static const double inputGap = 12.0;
  static const double formGap = 24.0;
}
