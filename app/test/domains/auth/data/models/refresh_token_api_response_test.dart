import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/data/models/refresh_token_api_response.dart';

void main() {
  group('RefreshTokenApiResponse', () {
    test('생성자 값이 그대로 유지된다', () {
      const response = RefreshTokenApiResponse(
        accessToken: 'access',
        accessTokenExpiresAt: 111,
        refreshToken: 'refresh',
        refreshTokenExpiresAt: 222,
      );

      expect(response.accessToken, 'access');
      expect(response.accessTokenExpiresAt, 111);
      expect(response.refreshToken, 'refresh');
      expect(response.refreshTokenExpiresAt, 222);
    });

    test('fromJson은 필드 값을 파싱한다', () {
      final response = RefreshTokenApiResponse.fromJson({
        'accessToken': 'access',
        'accessTokenExpiresAt': 111,
        'refreshToken': 'refresh',
        'refreshTokenExpiresAt': 222,
      });

      expect(response.accessToken, 'access');
      expect(response.accessTokenExpiresAt, 111);
      expect(response.refreshToken, 'refresh');
      expect(response.refreshTokenExpiresAt, 222);
    });
  });
}
