import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/core/entities/auth_token.dart';

import '../../../../utils/domains/test_auth_util.dart';

void main() {
  group('AuthToken', () {
    test('기본 tokenType은 Bearer', () {
      final token = TestAuthUtil.makeValidToken();
      expect(token.tokenType, 'Bearer');
    });

    test('custom tokenType 지정 가능', () {
      final token = AuthToken(
        accessToken: 'token',
        accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
        refreshToken: 'refresh',
        refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        tokenType: 'Custom',
      );
      expect(token.tokenType, 'Custom');
    });

    test('access token 만료 여부 판별', () {
      final expired = TestAuthUtil.makeExpiredToken();
      final valid = TestAuthUtil.makeValidToken();

      expect(expired.isAccessTokenExpired, isTrue);
      expect(valid.isAccessTokenExpired, isFalse);
    });

    test('refresh token 만료 여부 판별', () {
      final expired = TestAuthUtil.makeRefreshTokenExpired();
      final valid = TestAuthUtil.makeValidToken();

      expect(expired.isRefreshTokenExpired, isTrue);
      expect(valid.isRefreshTokenExpired, isFalse);
    });

    test('authorizationHeader는 tokenType과 accessToken을 포함', () {
      final token = TestAuthUtil.makeValidToken(accessToken: 'abc');
      expect(token.authorizationHeader, 'Bearer abc');
    });
  });
}
