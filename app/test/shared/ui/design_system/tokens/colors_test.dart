import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';

void main() {
  group('AppColors', () {
    test('brand colors getters return expected values', () {
      expect(AppColors.kakaoYellow.toARGB32(), 0xFFFEE500);
      expect(AppColors.googleBlue.toARGB32(), 0xFF4285F4);
      expect(AppColors.appleBlack.toARGB32(), 0xFF000000);
    });

    test('app colors getters return expected values', () {
      expect(AppColors.tomoPrimary100.toARGB32(), 0xFFFAF2E0);
      expect(AppColors.tomoPrimary200.toARGB32(), 0xFFF2E5CC);
      expect(AppColors.tomoPrimary300.toARGB32(), 0xFFEBD9B8);
      expect(AppColors.background.toARGB32(), 0xFFF2E5CC);
      expect(AppColors.border.toARGB32(), 0xFFE0E0E0);
      expect(AppColors.tomoWhite.toARGB32(), 0xFFE6E6E6);
      expect(AppColors.tomoBlack.toARGB32(), 0xFF212121);
      expect(AppColors.tomoDarkGray.toARGB32(), 0xFF8C8C8C);
      expect(AppColors.error.toARGB32(), 0xFFEB3030);
      expect(AppColors.success.toARGB32(), 0xFF219621);
      expect(AppColors.bluePrimary.toARGB32(), 0xFF0080FF);
    });

    test('neutral colors getters return expected values', () {
      expect(AppColors.white.toARGB32(), 0xFFFFFFFF);
    });
  });

  group('AppColors static maps', () {
    test('brandColors map contains expected values', () {
      expect(AppColors.brandColors['kakao']!.toARGB32(), 0xFFFEE500);
      expect(AppColors.brandColors['google']!.toARGB32(), 0xFF4285F4);
      expect(AppColors.brandColors['apple']!.toARGB32(), 0xFF000000);
    });

    test('socialButtons map contains expected values', () {
      expect(AppColors.socialButtons['kakao_bg']!.toARGB32(), 0xFFFEE500);
      expect(AppColors.socialButtons['kakao_text']!.toARGB32(), 0xD9000000);
      expect(AppColors.socialButtons['kakao_logo']!.toARGB32(), 0xFF000000);
      expect(AppColors.socialButtons['apple_bg']!.toARGB32(), 0xFFFFFFFF);
      expect(AppColors.socialButtons['apple_text']!.toARGB32(), 0xFF000000);
      expect(AppColors.socialButtons['google_bg']!.toARGB32(), 0xFFFFFFFF);
      expect(AppColors.socialButtons['google_text']!.toARGB32(), 0xFF000000);
    });

    test('appColors map contains expected values', () {
      expect(AppColors.appColors['primary_100']!.toARGB32(), 0xFFFAF2E0);
      expect(AppColors.appColors['primary_200']!.toARGB32(), 0xFFF2E5CC);
      expect(AppColors.appColors['primary_300']!.toARGB32(), 0xFFEBD9B8);
      expect(AppColors.appColors['background']!.toARGB32(), 0xFFF2E5CC);
      expect(AppColors.appColors['border']!.toARGB32(), 0xFFE0E0E0);
      expect(AppColors.appColors['white']!.toARGB32(), 0xFFE6E6E6);
      expect(AppColors.appColors['text_primary']!.toARGB32(), 0xFF212121);
      expect(AppColors.appColors['text_secondary']!.toARGB32(), 0xFF8C8C8C);
      expect(AppColors.appColors['error']!.toARGB32(), 0xFFEB3030);
      expect(AppColors.appColors['success']!.toARGB32(), 0xFF219621);
      expect(AppColors.appColors['blue_primary']!.toARGB32(), 0xFF0080FF);
    });

    test('neutralColors map contains expected values', () {
      expect(AppColors.neutralColors['white']!.toARGB32(), 0xFFFFFFFF);
      expect(AppColors.neutralColors['gray_500']!.toARGB32(), 0xFF8C8C8C);
      expect(AppColors.neutralColors['gray_900']!.toARGB32(), 0xFF212121);
      expect(AppColors.neutralColors['light_gray']!.toARGB32(), 0xFFD9D9D9);
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
