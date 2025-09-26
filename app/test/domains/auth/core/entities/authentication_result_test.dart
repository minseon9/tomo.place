import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/domains/auth/core/entities/authentication_result.dart';

import '../../../../utils/domains/test_auth_util.dart';

void main() {
  group('AuthenticationResult', () {
    group('생성자', () {
      test('필수 파라미터로 생성되어야 한다', () {
        const result = AuthenticationResult(status: AuthenticationStatus.authenticated);

        expect(result.status, AuthenticationStatus.authenticated);
        expect(result.token, isNull);
        expect(result.message, isNull);
      });

      test('토큰과 메시지를 포함할 수 있다', () {
        final token = TestAuthUtil.makeValidToken();

        final result = AuthenticationResult(
          status: AuthenticationStatus.authenticated,
          token: token,
          message: 'success',
        );

        expect(result.token, token);
        expect(result.message, 'success');
      });
    });

    group('factor y 생성자', () {
      test('authenticated factory', () {
        final token = TestAuthUtil.makeValidToken();

        final result = AuthenticationResult.authenticated(token);

        expect(result.status, AuthenticationStatus.authenticated);
        expect(result.token, token);
      });

      test('unauthenticated factory 기본 메시지', () {
        final result = AuthenticationResult.unauthenticated();

        expect(result.status, AuthenticationStatus.unauthenticated);
        expect(result.message, 'Authentication required');
      });

      test('unauthenticated factory 커스텀 메시지', () {
        final result = AuthenticationResult.unauthenticated('custom');

        expect(result.message, 'custom');
      });

      test('expired factory', () {
        final result = AuthenticationResult.expired();

        expect(result.status, AuthenticationStatus.expired);
        expect(result.message, 'Token expired');
      });
    });

    group('비즈니스 로직', () {
      test('status에 따라 인증 여부가 결정된다', () {
        final auth = AuthenticationResult.authenticated(TestAuthUtil.makeValidToken());
        final unauth = AuthenticationResult.unauthenticated();
        final expired = AuthenticationResult.expired();

        expect(auth.isAuthenticated(), isTrue);
        expect(unauth.isAuthenticated(), isFalse);
        expect(expired.isAuthenticated(), isFalse);
      });
    });
  });
}
