import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// DesignTokens 클래스를 직접 import하여 private constructor를 커버
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart'
    as design_tokens;
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';

void main() {
  group('AppColors', () {
    test('brand colors getters return expected values', () {
      expect(AppColors.kakaoYellow.value, 0xFFFEE500);
      expect(AppColors.googleBlue.value, 0xFF4285F4);
      expect(AppColors.appleBlack.value, 0xFF000000);
    });

    test('app colors getters return expected values', () {
      expect(AppColors.tomoPrimary100.value, 0xFFFAF2E0);
      expect(AppColors.tomoPrimary200.value, 0xFFF2E5CC);
      expect(AppColors.tomoPrimary300.value, 0xFFEBD9B8);
      expect(AppColors.background.value, 0xFFF2E5CC);
      expect(AppColors.border.value, 0xFFE0E0E0);
      expect(AppColors.tomoWhite.value, 0xFFE6E6E6);
      expect(AppColors.tomoBlack.value, 0xFF212121);
      expect(AppColors.tomoDarkGray.value, 0xFF8C8C8C);
      expect(AppColors.error.value, 0xFFEB3030);
      expect(AppColors.success.value, 0xFF219621);
      expect(AppColors.bluePrimary.value, 0xFF0080FF);
    });

    test('neutral colors getters return expected values', () {
      expect(AppColors.white.value, 0xFFFFFFFF);
    });
  });

  group('AppColors static maps', () {
    test('brandColors map contains expected values', () {
      expect(AppColors.brandColors['kakao']!.value, 0xFFFEE500);
      expect(AppColors.brandColors['google']!.value, 0xFF4285F4);
      expect(AppColors.brandColors['apple']!.value, 0xFF000000);
    });

    test('socialButtons map contains expected values', () {
      expect(AppColors.socialButtons['kakao_bg']!.value, 0xFFFEE500);
      expect(AppColors.socialButtons['kakao_text']!.value, 0xD9000000);
      expect(AppColors.socialButtons['kakao_logo']!.value, 0xFF000000);
      expect(AppColors.socialButtons['apple_bg']!.value, 0xFFFFFFFF);
      expect(AppColors.socialButtons['apple_text']!.value, 0xFF000000);
      expect(AppColors.socialButtons['google_bg']!.value, 0xFFFFFFFF);
      expect(AppColors.socialButtons['google_text']!.value, 0xFF000000);
    });

    test('appColors map contains expected values', () {
      expect(AppColors.appColors['primary_100']!.value, 0xFFFAF2E0);
      expect(AppColors.appColors['primary_200']!.value, 0xFFF2E5CC);
      expect(AppColors.appColors['primary_300']!.value, 0xFFEBD9B8);
      expect(AppColors.appColors['background']!.value, 0xFFF2E5CC);
      expect(AppColors.appColors['border']!.value, 0xFFE0E0E0);
      expect(AppColors.appColors['white']!.value, 0xFFE6E6E6);
      expect(AppColors.appColors['text_primary']!.value, 0xFF212121);
      expect(AppColors.appColors['text_secondary']!.value, 0xFF8C8C8C);
      expect(AppColors.appColors['error']!.value, 0xFFEB3030);
      expect(AppColors.appColors['success']!.value, 0xFF219621);
      expect(AppColors.appColors['blue_primary']!.value, 0xFF0080FF);
    });

    test('neutralColors map contains expected values', () {
      expect(AppColors.neutralColors['white']!.value, 0xFFFFFFFF);
      expect(AppColors.neutralColors['gray_500']!.value, 0xFF8C8C8C);
      expect(AppColors.neutralColors['gray_900']!.value, 0xFF212121);
      expect(AppColors.neutralColors['light_gray']!.value, 0xFFD9D9D9);
    });

    test('getters align with map values', () {
      expect(AppColors.kakaoYellow, AppColors.brandColors['kakao']);
      expect(AppColors.googleBlue, AppColors.brandColors['google']);
      expect(AppColors.appleBlack, AppColors.brandColors['apple']);
      expect(AppColors.tomoPrimary100, AppColors.appColors['primary_100']);
      expect(AppColors.tomoPrimary200, AppColors.appColors['primary_200']);
      expect(AppColors.tomoPrimary300, AppColors.appColors['primary_300']);
      expect(AppColors.background, AppColors.appColors['background']);
      expect(AppColors.border, AppColors.appColors['border']);
      expect(AppColors.tomoWhite, AppColors.appColors['white']);
      expect(AppColors.tomoBlack, AppColors.appColors['text_primary']);
      expect(AppColors.tomoDarkGray, AppColors.appColors['text_secondary']);
      expect(AppColors.error, AppColors.appColors['error']);
      expect(AppColors.success, AppColors.appColors['success']);
      expect(AppColors.bluePrimary, AppColors.appColors['blue_primary']);
      expect(AppColors.white, AppColors.neutralColors['white']);
    });
  });
}
