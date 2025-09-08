import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Apple SD Gothic Neo';

  static const TextStyle header1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32, // tomo-header1
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  static const TextStyle header2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24, // tomo-header2
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  static const TextStyle head3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    // tomo-head3
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: -0.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16, // tomo-body
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14, // tomo-button
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12, // tomo-chaption
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  // 기존 스타일들 유지 (다른 화면에서 사용)
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.5,
  );
}
