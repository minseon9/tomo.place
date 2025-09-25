import 'package:flutter/material.dart';

class AppColors {
  static const Map<String, Color> brandColors = {
    'kakao': Color(0xFFFEE500),
    'google': Color(0xFF4285F4),
    'apple': Color(0xFF000000),
  };

  static const Map<String, Color> socialButtons = {
    'kakao_bg': Color(0xFFFEE500),
    'kakao_text': Color(0xD9000000), // 85% opacity
    'kakao_logo': Color(0xFF000000),
    'apple_bg': Color(0xFFFFFFFF),
    'apple_text': Color(0xFF000000),
    'google_bg': Color(0xFFFFFFFF),
    'google_text': Color(0xFF000000),
  };

  static const Map<String, Color> appColors = {
    'primary_100': Color(0xFFFAF2E0), // tomo-primary100
    'primary_200': Color(0xFFF2E5CC), // tomo-primary200
    'primary_300': Color(0xFFEBD9B8), // tomo-primary300
    'background': Color(0xFFF2E5CC), // tomo-primary200
    'border': Color(0xFFE0E0E0),
    'white': Color(0xFFE6E6E6), // tomo-black
    'text_primary': Color(0xFF212121), // tomo-black
    'text_secondary': Color(0xFF8C8C8C), // tomo-darkgray
    'error': Color(0xFFEB3030), // Error-500
    'success': Color(0xFF219621), // Success-500
    'blue_primary': Color(0xFF0080FF), // 파란색 링크/버튼
  };

  static const Map<String, Color> neutralColors = {
    'white': Color(0xFFFFFFFF),
    'gray_500': Color(0xFF8C8C8C), // tomo-darkgray
    'gray_900': Color(0xFF212121), // tomo-black
    'light_gray': Color(0xFFD9D9D9), // tomo-lightgray
  };

  static Color get kakaoYellow => brandColors['kakao']!;

  static Color get googleBlue => brandColors['google']!;

  static Color get appleBlack => brandColors['apple']!;

  static Color get tomoPrimary100 => appColors['primary_100']!;

  static Color get tomoPrimary200 => appColors['primary_200']!;

  static Color get tomoPrimary300 => appColors['primary_300']!;

  static Color get tomoWhite => appColors['white']!;

  static Color get tomoBlack => appColors['text_primary']!;

  static Color get tomoDarkGray => appColors['text_secondary']!;

  static Color get background => appColors['background']!;

  static Color get border => appColors['border']!;

  static Color get white => neutralColors['white']!;

  static Color get error => appColors['error']!;

  static Color get success => appColors['success']!;

  static Color get bluePrimary => appColors['blue_primary']!;
}
