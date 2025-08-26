import 'package:flutter/material.dart';

/// Figma Variables에서 추출한 디자인 토큰
/// 
/// 이 클래스는 Figma MCP를 통해 자동 생성되는 색상 시스템입니다.
/// 수동으로 수정하지 마세요. Figma에서 변경 후 재생성하세요.
class DesignTokens {
  DesignTokens._();

  /// 브랜드 색상 (Figma Variables: Brand Colors)
  static const Map<String, Color> brandColors = {
    'kakao': Color(0xFFFEE500),
    'google': Color(0xFF4285F4),
    'apple': Color(0xFF000000),
  };

  /// 소셜 버튼 색상 (Figma Variables: Social Buttons)
  static const Map<String, Color> socialButtons = {
    'kakao_bg': Color(0xFFFEE500),
    'kakao_text': Color(0xD9000000), // 85% opacity
    'apple_bg': Color(0xFFFFFFFF),
    'apple_text': Color(0xFF000000),
    'google_bg': Color(0xFFFFFFFF),
    'google_text': Color(0xFF000000),
  };

  /// 앱 공통 색상 (Figma Variables: App Colors)
  static const Map<String, Color> appColors = {
    'primary_200': Color(0xFFF2E5CC),
    'background': Color(0xFFF2E5CC), // tomo-primary200
    'border': Color(0xFFE0E0E0),
    'text_primary': Color(0xFF212121), // tomo-black
    'text_secondary': Color(0xFF8C8C8C), // tomo-darkgray
    'error': Color(0xFFFF4444),
    'success': Color(0xFF4CAF50),
  };

  /// 컨벤션: 직접 색상 접근을 위한 헬퍼
  static Color get kakaoYellow => brandColors['kakao']!;
  static Color get googleBlue => brandColors['google']!;
  static Color get appleBlack => brandColors['apple']!;
  static Color get tomoPrimary => appColors['primary_200']!;
  static Color get background => appColors['background']!;
  static Color get border => appColors['border']!;
}
