import 'package:flutter_test/flutter_test.dart';
import 'package:app/domains/auth/consts/social_provider.dart';

void main() {
  group('SocialProvider', () {
    test('모든 enum 값이 올바르게 정의되어야 한다', () {
      expect(SocialProvider.values, hasLength(3));
      expect(SocialProvider.values, contains(SocialProvider.kakao));
      expect(SocialProvider.values, contains(SocialProvider.apple));
      expect(SocialProvider.values, contains(SocialProvider.google));
    });

    test('각 provider가 올바른 code를 가져야 한다', () {
      expect(SocialProvider.kakao.code, 'KAKAO');
      expect(SocialProvider.apple.code, 'APPLE');
      expect(SocialProvider.google.code, 'GOOGLE');
    });

    test('enum 값의 순서가 올바르게 정의되어야 한다', () {
      expect(SocialProvider.values.indexOf(SocialProvider.kakao), 0);
      expect(SocialProvider.values.indexOf(SocialProvider.apple), 1);
      expect(SocialProvider.values.indexOf(SocialProvider.google), 2);
    });

    test('enum 값이 올바른 문자열로 변환되어야 한다', () {
      expect(SocialProvider.kakao.toString(), 'SocialProvider.kakao');
      expect(SocialProvider.apple.toString(), 'SocialProvider.apple');
      expect(SocialProvider.google.toString(), 'SocialProvider.google');
    });

    test('enum 값이 올바르게 비교되어야 한다', () {
      expect(SocialProvider.kakao == SocialProvider.kakao, isTrue);
      expect(SocialProvider.kakao == SocialProvider.apple, isFalse);
      expect(SocialProvider.apple == SocialProvider.apple, isTrue);
      expect(SocialProvider.google == SocialProvider.google, isTrue);
    });

    test('code 값이 올바르게 비교되어야 한다', () {
      expect(SocialProvider.kakao.code == 'KAKAO', isTrue);
      expect(SocialProvider.apple.code == 'APPLE', isTrue);
      expect(SocialProvider.google.code == 'GOOGLE', isTrue);
      expect(SocialProvider.kakao.code == 'APPLE', isFalse);
    });
  });
}
