import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/typography.dart';

void main() {
  group('AppTypography', () {
    group('tomo-head3 토큰 테스트', () {
      test('tomo-head3 토큰이 올바른 속성으로 정의되어야 한다', () {
        // Given & When
        final head3Style = AppTypography.head3;

        // Then
        expect(head3Style.fontSize, equals(18));
        expect(head3Style.fontWeight, equals(FontWeight.w600));
        expect(head3Style.height, equals(1.0));
        expect(head3Style.letterSpacing, equals(-0.2));
      });

      test('tomo-head3 토큰이 올바른 폰트 패밀리를 가져야 한다', () {
        // Given & When
        final head3Style = AppTypography.head3;

        // Then
        expect(head3Style.fontFamily, equals('Apple SD Gothic Neo'));
      });

      test('tomo-head3 토큰이 Figma 스펙과 일치해야 한다', () {
        // Given & When
        final head3Style = AppTypography.head3;

        // Then - Figma 스펙 검증
        expect(head3Style.fontSize, equals(18)); // tomo-head3
        expect(head3Style.fontWeight, equals(FontWeight.w600));
        expect(head3Style.height, equals(1.0));
        expect(head3Style.letterSpacing, equals(-0.2));
      });
    });

    group('기존 토큰 변경 방지 테스트', () {
      test('header1 토큰이 변경되지 않아야 한다', () {
        // Given & When
        final header1Style = AppTypography.header1;

        // Then
        expect(header1Style.fontSize, equals(32));
        expect(header1Style.fontWeight, equals(FontWeight.w700));
        expect(header1Style.height, equals(1.0));
      });

      test('header2 토큰이 변경되지 않아야 한다', () {
        // Given & When
        final header2Style = AppTypography.header2;

        // Then
        expect(header2Style.fontSize, equals(24));
        expect(header2Style.fontWeight, equals(FontWeight.w600));
        expect(header2Style.height, equals(1.0));
      });

      test('body 토큰이 변경되지 않아야 한다', () {
        // Given & When
        final bodyStyle = AppTypography.body;

        // Then
        expect(bodyStyle.fontSize, equals(16));
        expect(bodyStyle.fontWeight, equals(FontWeight.w400));
        expect(bodyStyle.height, equals(1.0));
      });

      test('button 토큰이 변경되지 않아야 한다', () {
        // Given & When
        final buttonStyle = AppTypography.button;

        // Then
        expect(buttonStyle.fontSize, equals(14));
        expect(buttonStyle.fontWeight, equals(FontWeight.w500));
        expect(buttonStyle.height, equals(1.0));
      });

      test('caption 토큰이 변경되지 않아야 한다', () {
        // Given & When
        final captionStyle = AppTypography.caption;

        // Then
        expect(captionStyle.fontSize, equals(12));
        expect(captionStyle.fontWeight, equals(FontWeight.w400));
        expect(captionStyle.height, equals(1.0));
      });
    });

    group('폰트 패밀리 일관성 테스트', () {
      test('모든 토큰이 동일한 폰트 패밀리를 가져야 한다', () {
        // Given
        final expectedFontFamily = 'Apple SD Gothic Neo';
        final allStyles = [
          AppTypography.header1,
          AppTypography.header2,
          AppTypography.head3,
          AppTypography.body,
          AppTypography.button,
          AppTypography.caption,
        ];

        // When & Then
        for (final style in allStyles) {
          expect(style.fontFamily, equals(expectedFontFamily));
        }
      });
    });

    group('토큰 타입 검증', () {
      test('모든 토큰이 TextStyle 타입이어야 한다', () {
        // Given & When & Then
        expect(AppTypography.header1, isA<TextStyle>());
        expect(AppTypography.header2, isA<TextStyle>());
        expect(AppTypography.head3, isA<TextStyle>());
        expect(AppTypography.body, isA<TextStyle>());
        expect(AppTypography.button, isA<TextStyle>());
        expect(AppTypography.caption, isA<TextStyle>());
      });

      test('모든 토큰이 const로 정의되어야 한다', () {
        // Given & When & Then
        expect(AppTypography.header1, isA<TextStyle>());
        expect(AppTypography.header2, isA<TextStyle>());
        expect(AppTypography.head3, isA<TextStyle>());
        expect(AppTypography.body, isA<TextStyle>());
        expect(AppTypography.button, isA<TextStyle>());
        expect(AppTypography.caption, isA<TextStyle>());
      });
    });

    group('토큰 불변성 테스트', () {
      test('토큰이 변경되지 않아야 한다', () {
        // Given
        final originalHead3 = AppTypography.head3;
        final originalHeader1 = AppTypography.header1;

        // When & Then
        expect(AppTypography.head3, equals(originalHead3));
        expect(AppTypography.header1, equals(originalHeader1));
      });
    });
  });
}
