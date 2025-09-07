import 'package:flutter_test/flutter_test.dart';
import 'package:app/domains/auth/consts/social_label_variant.dart';

void main() {
  group('SocialLabelVariant', () {
    test('모든 enum 값이 올바르게 정의되어야 한다', () {
      expect(SocialLabelVariant.values, hasLength(2));
      expect(SocialLabelVariant.values, contains(SocialLabelVariant.login));
      expect(SocialLabelVariant.values, contains(SocialLabelVariant.signup));
    });

    test('enum 값의 순서가 올바르게 정의되어야 한다', () {
      expect(SocialLabelVariant.values.indexOf(SocialLabelVariant.login), 0);
      expect(SocialLabelVariant.values.indexOf(SocialLabelVariant.signup), 1);
    });

    test('enum 값이 올바른 문자열로 변환되어야 한다', () {
      expect(SocialLabelVariant.login.toString(), 'SocialLabelVariant.login');
      expect(SocialLabelVariant.signup.toString(), 'SocialLabelVariant.signup');
    });

    test('enum 값이 올바르게 비교되어야 한다', () {
      expect(SocialLabelVariant.login == SocialLabelVariant.login, isTrue);
      expect(SocialLabelVariant.login == SocialLabelVariant.signup, isFalse);
      expect(SocialLabelVariant.signup == SocialLabelVariant.signup, isTrue);
    });
  });
}
