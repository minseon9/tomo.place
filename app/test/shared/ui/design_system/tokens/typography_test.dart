import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/typography.dart';

void main() {
  group('AppTypography', () {
    group('토큰 테스트', () {
      test('tomo-header1 토큰이 올바른 속성으로 정의되어야 한다', () {
        final header1Style = AppTypography.header1;

        expect(header1Style.fontFamily, equals('Apple SD Gothic Neo'));
        expect(header1Style.fontSize, equals(32));
        expect(header1Style.fontWeight, equals(FontWeight.w700));
        expect(header1Style.height, equals(1.0));
        expect(header1Style.letterSpacing, isNull);
      });

      test('tomo-header2 토큰이 올바른 속성으로 정의되어야 한다', () {
        final header2Style = AppTypography.header2;

        expect(header2Style.fontFamily, equals('Apple SD Gothic Neo'));
        expect(header2Style.fontSize, equals(24));
        expect(header2Style.fontWeight, equals(FontWeight.w600));
        expect(header2Style.height, equals(1.0));
        expect(header2Style.letterSpacing, isNull);
      });

      test('tomo-head3 토큰이 올바른 속성으로 정의되어야 한다', () {
        // Given & When
        final head3Style = AppTypography.head3;

        // Then
        expect(head3Style.fontFamily, equals('Apple SD Gothic Neo'));
        expect(head3Style.fontSize, equals(18));
        expect(head3Style.fontWeight, equals(FontWeight.w600));
        expect(head3Style.height, equals(1.0));
        expect(head3Style.letterSpacing, equals(-0.2));
      });

      test('tomo-header3 토큰이 올바른 속성으로 정의되어야 한다', () {
        final header3Style = AppTypography.header3;

        expect(header3Style.fontFamily, equals('Apple SD Gothic Neo'));
        expect(header3Style.fontSize, equals(20));
        expect(header3Style.fontWeight, equals(FontWeight.w600));
        expect(header3Style.height, equals(1.0));
        expect(header3Style.letterSpacing, equals(-0.4));
      });

      test('tomo-body 토큰이 올바른 속성으로 정의되어야 한다', () {
        final bodyStyle = AppTypography.body;

        expect(bodyStyle.fontFamily, equals('Apple SD Gothic Neo'));
        expect(bodyStyle.fontSize, equals(16));
        expect(bodyStyle.fontWeight, equals(FontWeight.w400));
        expect(bodyStyle.height, equals(1.0));
        expect(bodyStyle.letterSpacing, isNull);
      });

      test('tomo-button 토큰이 올바른 속성으로 정의되어야 한다', () {
        final buttonStyle = AppTypography.button;

        expect(buttonStyle.fontFamily, equals('Apple SD Gothic Neo'));
        expect(buttonStyle.fontSize, equals(14));
        expect(buttonStyle.fontWeight, equals(FontWeight.w500));
        expect(buttonStyle.height, equals(1.0));
        expect(buttonStyle.letterSpacing, isNull);
      });

      test('tomo-caption 토큰이 올바른 속성으로 정의되어야 한다', () {
        final captionStyle = AppTypography.caption;

        expect(captionStyle.fontFamily, equals('Apple SD Gothic Neo'));
        expect(captionStyle.fontSize, equals(12));
        expect(captionStyle.fontWeight, equals(FontWeight.w400));
        expect(captionStyle.height, equals(1.0));
        expect(captionStyle.letterSpacing, isNull);
      });

      test('bold 토큰이 올바른 속성으로 정의되어야 한다', () {
        final boldStyle = AppTypography.bold;

        expect(boldStyle.fontFamily, equals('Apple SD Gothic Neo'));
        expect(boldStyle.fontSize, equals(12));
        expect(boldStyle.fontWeight, equals(FontWeight.w700));
        expect(boldStyle.height, equals(1.0));
        expect(boldStyle.letterSpacing, isNull);
      });

      test('h1 토큰이 올바른 속성으로 정의되어야 한다', () {
        final h1Style = AppTypography.h1;

        expect(h1Style.fontFamily, equals('Apple SD Gothic Neo'));
        expect(h1Style.fontSize, equals(32));
        expect(h1Style.fontWeight, equals(FontWeight.w700));
        expect(h1Style.height, equals(1.25));
        expect(h1Style.letterSpacing, equals(-0.5));
      });

      test('h2 토큰이 올바른 속성으로 정의되어야 한다', () {
        final h2Style = AppTypography.h2;

        expect(h2Style.fontFamily, equals('Apple SD Gothic Neo'));
        expect(h2Style.fontSize, equals(24));
        expect(h2Style.fontWeight, equals(FontWeight.w600));
        expect(h2Style.height, equals(1.3));
        expect(h2Style.letterSpacing, equals(-0.3));
      });

      test('h3 토큰이 올바른 속성으로 정의되어야 한다', () {
        final h3Style = AppTypography.h3;

        expect(h3Style.fontFamily, equals('Apple SD Gothic Neo'));
        expect(h3Style.fontSize, equals(20));
        expect(h3Style.fontWeight, equals(FontWeight.w600));
        expect(h3Style.height, equals(1.4));
        expect(h3Style.letterSpacing, equals(-0.2));
      });

      test('bodyLarge 토큰이 올바른 속성으로 정의되어야 한다', () {
        final bodyLargeStyle = AppTypography.bodyLarge;

        expect(bodyLargeStyle.fontFamily, equals('Apple SD Gothic Neo'));
        expect(bodyLargeStyle.fontSize, equals(16));
        expect(bodyLargeStyle.fontWeight, equals(FontWeight.w400));
        expect(bodyLargeStyle.height, equals(1.5));
        expect(bodyLargeStyle.letterSpacing, equals(0));
      });

      test('bodyMedium 토큰이 올바른 속성으로 정의되어야 한다', () {
        final bodyMediumStyle = AppTypography.bodyMedium;

        expect(bodyMediumStyle.fontFamily, equals('Apple SD Gothic Neo'));
        expect(bodyMediumStyle.fontSize, equals(14));
        expect(bodyMediumStyle.fontWeight, equals(FontWeight.w400));
        expect(bodyMediumStyle.height, equals(1.4));
        expect(bodyMediumStyle.letterSpacing, equals(0));
      });

      test('bodySmall 토큰이 올바른 속성으로 정의되어야 한다', () {
        final bodySmallStyle = AppTypography.bodySmall;

        expect(bodySmallStyle.fontFamily, equals('Apple SD Gothic Neo'));
        expect(bodySmallStyle.fontSize, equals(12));
        expect(bodySmallStyle.fontWeight, equals(FontWeight.w400));
        expect(bodySmallStyle.height, equals(1.3));
        expect(bodySmallStyle.letterSpacing, equals(0.1));
      });

      test('buttonLarge 토큰이 올바른 속성으로 정의되어야 한다', () {
        final buttonLargeStyle = AppTypography.buttonLarge;

        expect(buttonLargeStyle.fontFamily, equals('Apple SD Gothic Neo'));
        expect(buttonLargeStyle.fontSize, equals(16));
        expect(buttonLargeStyle.fontWeight, equals(FontWeight.w600));
        expect(buttonLargeStyle.height, equals(1.0));
        expect(buttonLargeStyle.letterSpacing, equals(0));
      });

      test('buttonMedium 토큰이 올바른 속성으로 정의되어야 한다', () {
        final buttonMediumStyle = AppTypography.buttonMedium;

        expect(buttonMediumStyle.fontFamily, equals('Apple SD Gothic Neo'));
        expect(buttonMediumStyle.fontSize, equals(14));
        expect(buttonMediumStyle.fontWeight, equals(FontWeight.w500));
        expect(buttonMediumStyle.height, equals(1.0));
        expect(buttonMediumStyle.letterSpacing, equals(0));
      });

      test('overline 토큰이 올바른 속성으로 정의되어야 한다', () {
        final overlineStyle = AppTypography.overline;

        expect(overlineStyle.fontFamily, equals('Apple SD Gothic Neo'));
        expect(overlineStyle.fontSize, equals(10));
        expect(overlineStyle.fontWeight, equals(FontWeight.w500));
        expect(overlineStyle.height, equals(1.0));
        expect(overlineStyle.letterSpacing, equals(0.5));
      });
    });
  });
}
